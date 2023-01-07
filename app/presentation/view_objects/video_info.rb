# frozen_string_literal: true

require_relative 'comment_list'
require_relative 'sentiment_list'

module Views
  # View for a single video entity
  class VideoInfo
    def initialize(video, comments, sentiments, sentiment_selected, view = nil)
      @video = video
      @comments = CommentList.new(comments)
      sentiments.insert(0, { sentiment: 'All' })
      @sentiments = SentimentList.new(sentiments)
      @sentiment_selected = sentiment_selected
      @view = view
    end

    attr_reader :video, :comments, :sentiments, :sentiment_selected, :view

    def comments_summary
      { title: 'Comments Summary by Sentiment',
        positive_count: @comments.positive_count,
        neutral_count: @comments.neutral_count,
        negative_count: @comments.negative_count,
        mixed_count: @comments.mixed_count }
    end

    def show_comments?
      @view == 'comments' && @comments.any?
    end

    def show_comments_trend?
      @view == 'comments-trend' && @comments.any?
    end

    def show_video_trend?
      @view == 'video-trend' && @comments.any?
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

    def all_comments_url
      "/videos/#{origin_id}"
    end

    def sentiment_comments_url(sentiment_id)
      "/videos/#{origin_id}?sentiment=#{sentiment_id}"
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
