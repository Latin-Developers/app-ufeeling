# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video with comments from Youtube API to database
    class AddVideo
      include Dry::Transaction

      step :parse_url
      step :request_video
      step :reify_video

      private

      def parse_url(input)
        if input.success?
          includes_other_params = input[:video_url].include? '&'
          video_id = includes_other_params ? input[:video_url].split('=')[-2] : input[:video_url].split('=')[-1]
          Success(video_id:)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def request_video(input)
        result = UFeeling::Gateway::Api.new(UFeeling::App.config)
          .add_video(input[:video_id])

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect
        puts e.backtrace
        Failure('Cannot add videos right now; please try again later')
      end

      def reify_video(video_json)
        Representer::Video.new(OpenStruct.new)
          .from_json(video_json)
          .then { |video| Success(video) }
      rescue StandardError
        Failure('Error in the video -- please try again')
      end
    end
  end
end
