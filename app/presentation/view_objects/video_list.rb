# frozen_string_literal: true

require_relative 'video_info'

module Views
  # View for a a list of video entities
  class VideoList
    def initialize(videos)
      @videos = videos.map.with_index { |video, i| VideoInfo.new(video, [], [], nil, i) }
    end

    def each(&)
      @videos.each(&)
    end

    def each_withouth(filter_ids, &)
      @videos.reject { |video| filter_ids.include?(video.origin_id) }.each(&)
    end

    def ids
      @videos.map(&:origin_id)
    end

    def any?
      @videos.any?
    end
  end
end
