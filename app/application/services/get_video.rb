# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetVideo
      include Dry::Transaction

      step :get_video
      step :format_video
      step :obtain_sentiments
      step :format_sentiments
      step :get_comments
      step :format_comments
      # TODO: step :get_summary
      # TODO: step :format_summary

      private

      def get_video(input)
        result = UFeeling::Gateway::Api.new(UFeeling::App.config)
          .get_video(input[:video_id])
        input[:video_json] = result.payload
        input[:processing] = result.processing?

        result.success? ? Success(input) : Failure(result.message)
        # rescue StandardError
        #   Failure('Could not obtain video')
      end

      def format_video(input)
        unless input[:processing]
          Representer::Video.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
            .from_json(input[:video_json])
            .then { |video| input[:video] = video }
        end

        Success(input)
      rescue StandardError
        Failure('Could not parse response from API')
      end

      def obtain_sentiments(input)
        unless input[:processing]
          UFeeling::Gateway::Api.new(UFeeling::App.config).obtain_sentiments
            .then do |result|
              input[:sentiments_json] = result.payload
              result.success? ? Success(input) : Failure(result.message)
            end
        end

        Success(input)
      rescue StandardError
        Failure('Could not get sentiments available')
      end

      def format_sentiments(input)
        unless input[:processing]
          Representer::SentimentsList.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
            .from_json(input[:sentiments_json])
            .then { |sentiments| input[:sentiments] = sentiments }
        end

        Success(input)
      rescue StandardError
        Failure('Could not format sentiments available')
      end

      def get_comments(input)
        unless input[:processing]
          UFeeling::Gateway::Api.new(UFeeling::App.config).comments_list(input[:video_id])
            .then do |result|
              input[:comments_json] = result.payload
              result.success? ? Success(input) : Failure(result.message)
            end
        end

        Success(input)
      rescue StandardError
        Failure('Could not obtain comments')
      end

      def format_comments(input)
        unless input[:processing]
          Representer::CommentsList.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
            .from_json(input[:comments_json])
            .then do |comments|
              input[:comments] = comments
            end
        end

        Success(input)
      rescue StandardError
        Failure('Could not parse response from comments')
      end
    end
  end
end
