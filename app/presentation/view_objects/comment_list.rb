# frozen_string_literal: true

require_relative 'comment_info'

module Views
  # View for a a list of video entities
  class CommentList
    def initialize(comments)
      @comments = comments&.map&.with_index { |comment, i| CommentInfo.new(comment, i) }
    end

    def each(&)
      @comments.each(&)
    end

    def positive_count
      @comments.select(&:positive?).size
    end

    def neutral_count
      @comments.select(&:neutral?).size
    end

    def negative_count
      @comments.select(&:negative?).size
    end

    def mixed_count
      @comments.select(&:mixed?).size
    end

    def any?
      @comments.any?
    end
  end
end
