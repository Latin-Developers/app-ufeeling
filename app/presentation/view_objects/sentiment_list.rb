# frozen_string_literal: true

require_relative 'sentiment_info'

module Views
  # View for a a list of video entities
  class SentimentList
    def initialize(sentiments)
      @sentiments = sentiments.map.with_index { |sentiment, i| SentimentInfo.new(sentiment, i) }
    end

    def each(&)
      @sentiments.each(&)
    end

    def any?
      @sentiments.any?
    end
  end
end
