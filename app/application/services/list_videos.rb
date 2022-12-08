# frozen_string_literal: true

require 'dry/monads'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class ListVideos
      include Dry::Transaction

      step :get_api_list
      step :reify_list

      private

      def get_api_list(video_lists)
        UFeeling::Gateway::Api.new(UFeeling::App.config)
          .video_list(video_lists)
          .then do |result|
            result.success? ? Success(result.payload) : Failure(result.message)
          end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(videos_json)
        Representer::VideosList.new(OpenStruct.new)
          .from_json(videos_json)
          .then { |videos| Success(videos) }
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end
