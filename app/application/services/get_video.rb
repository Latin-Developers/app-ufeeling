# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetVideo
      include Dry::Transaction

      step :get_video
      step :format_video
      # step :get_comments
      # TODO: step :format_comments
      # TODO: step :get_summary
      # TODO: step :format_summary

      private

      def get_video(input)
        result = UFeeling::Gateway::Api.new(UFeeling::App.config)
          .get_video(input[:video_id])

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure('Could not obtain video')
      end

      def format_video(video_json)
        Representer::Video.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
          .from_json(video_json)
          .then { |video| Success(video:) }
      rescue StandardError
        Failure('Could not parse response from API')
      end

      def get_comments(input)
        UFeeling::Gateway::Api.new(UFeeling::App.config).comments_list
          .then do |result|
            input[:comments_json] = result.payload
            result.success? ? Success(input) : Failure(result.message)
          end
      rescue StandardError
        Failure('Could not obtain comments')
      end

      # #HERE COPY AS HOME
      def format_comments(input)
        Representer::Comment.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
          .from_json(input[:comments_json])
          .then { |comment| Success(comment:) }
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end
