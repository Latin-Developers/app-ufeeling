# frozen_string_literal: true

module Views
  # View object to capture progress bar information
  class VideoProcessing
    def initialize(config, processing, video_id)
      @config = config
      @processing = processing
      @video_id = video_id
    end

    def in_progress?
      @processing
    end

    def ws_channel_id
      @video_id if in_progress?
    end

    def ws_javascript
      "#{@config.API_HOST}/faye/faye.js" if in_progress?
    end

    def ws_route
      "#{@config.API_HOST}/faye/faye" if in_progress?
    end
  end
end
