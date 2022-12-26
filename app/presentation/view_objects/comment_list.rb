# frozen_string_literal: true

require_relative 'comment_info'

module Views
  # View for a a list of video entities
  class CommentList
    def initialize(comments)
      @comments = comments.map.with_index { |comment, i| CommentInfo.new(comment, i) }
    end

    def each(&)
      @comments.each(&)
    end

    def any?
      @comments.any?
    end
  end
end
