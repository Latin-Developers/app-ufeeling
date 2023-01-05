# frozen_string_literal: true

require_relative 'comment_list'

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
      { title: 'Comments Summary by Sentiment',
        positive_count: @comments.positive_count,
        neutral_count: @comments.neutral_count,
        negative_count: @comments.negative_count }
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

    def published_date
      year = published_info.year.to_s.rjust(4, '0')
      month = published_info.month.to_s.rjust(2, '0')
      day = published_info.day.to_s.rjust(2, '0')
      "#{year}-#{month}-#{day}"
    end

    def author_name
      author.name
    end

    private

    def author
      @video[:author]
    end

    def published_info
      @video.published_info
    end
  end
end
