# frozen_string_literal: true

require_relative 'comment_info'

module Views
  # View for a a list of video entities
  class CommentList
    def initialize(comments)
      @comments = comments&.map&.with_index { |comment, i| CommentInfo.new(comment, i) }
    end

    def each(&)
      @comments.sort { |a, b| b.published_date <=> a.published_date }.each(&)
    end

    def dates
      @comments.map(&:published_date).uniq!.sort
    end

    def positive_count(date: nil)
      @comments.select { |c| c.positive? && (date.nil? || date == c.published_date) }.size
    end

    def neutral_count(date: nil)
      @comments.select { |c| c.neutral? && (date.nil? || date == c.published_date) }.size
    end

    def negative_count(date: nil)
      @comments.select { |c| c.negative? && (date.nil? || date == c.published_date) }.size
    end

    def mixed_count(date: nil)
      @comments.select { |c| c.mixed? && (date.nil? || date == c.published_date) }.size
    end

    def any?
      @comments.any?
    end
  end
end
