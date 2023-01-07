# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video with comments from Youtube API to database
    class AddVideo
      include Dry::Transaction

      step :parse_url
      step :request_video_from_api
      step :format_video

      private

      def parse_url(input)
        if input.success?
          from_param_fild = input[:video_url].include?('https://youtu.be/') || input[:video_url].include?('https://youtube.com/shorts/')
          video_id = from_param_fild ? video_id_from_param_fild(input[:video_url]) : video_id_query_field(input[:video_url])
          Success(video_id:)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def request_video_from_api(input)
        result = UFeeling::Gateway::Api.new(UFeeling::App.config)
          .add_video(input[:video_id])

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect
        puts e.backtrace
        Failure('Cannot add videos right now; please try again later')
      end

      def format_video(video_json)
        Representer::Video.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
          .from_json(video_json)
          .then { |video| Success(video) }
      rescue StandardError
        Failure('Error in the video -- please try again')
      end

      def video_id_from_param_fild(video_url)
        video_url.split('?')[0].split('/')[-1]
      end

      def video_id_query_field(video_url)
        includes_other_params = video_url.include? '&'
        includes_other_params ? video_url.split('=')[-2] : video_url.split('=')[-1]
      end
    end
  end
end
