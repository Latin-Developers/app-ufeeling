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

    def text_display
      @comment[:text_display]
    end

    def total_reply_count
      @comment[:total_reply_count]
    end

    def sentiment
      @comment[:sentiment]
    end

    def published_info
      @comment[:published_info]
    end
  end
end
