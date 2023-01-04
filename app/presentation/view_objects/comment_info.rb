# frozen_string_literal: true

module Views
  # View for a single video entity
  class CommentInfo
    def initialize(comment, index = nil)
      @comment = comment
      @index = index
    end

    attr_reader :comment

    def origin_id
      @comment[:origin_id]
    end

    def text_original
      @comment[:text_original]
    end

    def total_reply_count
      @comment[:total_reply_count]
    end

    def positive?
      sentiment.sentiment_name == 'positive'
    end

    def neutral?
      sentiment.sentiment_name == 'neutral'
    end

    def negative?
      sentiment.sentiment_name == 'negative'
    end

    def sentiment
      @comment[:sentiment]
    end

    def published_info
      @comment[:published_info]
    end
  end
end
