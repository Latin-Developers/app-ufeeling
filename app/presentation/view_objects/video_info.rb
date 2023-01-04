# frozen_string_literal: true

require_relative 'comment_list'
require 'gchart'

module Views
  # View for a single video entity
  class VideoInfo
    def initialize(video, comments, index = nil)
      @video = video
      @comments = CommentList.new(comments)
      @index = index
    end

    attr_reader :video, :comments

    def comments_summary
      Gchart.pie(
        title: 'Comments Summary by Sentiment',
        title_text_style: { color: 'ffffff' },
        labels: %w[Positive Neutral Negative],
        bar_colors: %w[5db85b ffc008 d9534f],
        bg: '0f2437',
        data: [@comments.positive_count, @comments.neutral_count, @comments.negative_count]
      )
    end

    def video_image
      @video[:thumbnail_url]
    end

    def video_title
      @video[:title]
    end

    def video_description
      @video[:description]
    end

    def origin_id
      @video[:origin_id]
    end
  end
end
