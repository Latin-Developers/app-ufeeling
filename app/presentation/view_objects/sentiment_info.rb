# frozen_string_literal: true

module Views
  # View for a single video entity
  class SentimentInfo
    def initialize(sentiment, index = nil)
      @sentiment = sentiment
      @index = index
    end

    attr_reader :sentiment

    def id
      @sentiment[:id]
    end

    def name_display
      @sentiment[:sentiment].capitalize
    end

    def name
      @sentiment[:sentiment]
    end
  end
end
