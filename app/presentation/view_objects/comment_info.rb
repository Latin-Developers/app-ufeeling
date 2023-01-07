# frozen_string_literal: true

module Views
  # View for a single video entity
  class CommentInfo
    def initialize(comment, index = nil)
      @comment = comment
      @index = index
    end

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

    def mixed?
      sentiment.sentiment_name == 'mixed'
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

    def language_name
      language.language_name
    end

    def language_code
      language.language_code
    end

    private

    def sentiment
      @comment[:sentiment]
    end

    def author
      @comment[:author]
    end

    def published_info
      @comment.published_info
    end

    def language
      @comment[:language]
    end
  end
end
