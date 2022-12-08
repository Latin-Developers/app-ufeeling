# frozen_string_literal: true

require_relative 'list_request'
require 'http'

module UFeeling
  module Gateway
    # Infrastructure to call UFeeling API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def video_list(video_ids)
        @request.video_list(video_ids)
      end

      def add_video(video_id)
        @request.add_video(video_id)
      end

      def get_video(video_id)
        @request.get_video(video_id)
      end

      # TODO: get_comments
      # TODO get_sentiment_summary
      # TODO get_sentiment_trend

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def video_list(video_ids)
          call_api('get', ['videos'],
                   'video_ids' => Value::WatchedList.to_encoded(video_ids))
        end

        def get_video(video_id)
          call_api('get', ['videos', video_id])
        end

        def add_video(video_id)
          call_api('post', ['videos', video_id])
        end

        # TODO: get_comments
        # TODO get_sentiment_summary
        # TODO get_sentiment_trend

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
            .then { |str| str ? "?#{str}" : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
            .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_CODES = (200..299)

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def message
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
