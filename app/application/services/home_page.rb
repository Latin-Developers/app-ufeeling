# frozen_string_literal: true

require 'dry/monads'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class HomePage
      include Dry::Transaction

      step :get_previous_videos
      step :format_previous_videos
      # TODO: step :get_categories
      # TODO: step :format_categories
      # TODO: step :get_videos_by_category
      # TODO: step :format_videos_by_category

      private

      def get_previous_videos(input)
        if input[:video_ids].size.zero?
          Success('{"videos": []}')
        else
          UFeeling::Gateway::Api.new(UFeeling::App.config).video_list(input[:video_ids])
            .then do |result|
              result.success? ? Success(result.payload) : Failure(result.message)
            end
        end
      rescue StandardError
        Failure('Could not access our API')
      end

      def format_previous_videos(videos_json)
        Representer::VideosList.new(OpenStruct.new)
          .from_json(videos_json)
          .then { |videos| Success(videos) }
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end
