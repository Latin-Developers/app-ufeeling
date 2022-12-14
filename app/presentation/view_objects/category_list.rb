# frozen_string_literal: true

require_relative 'category_info'

module Views
  # View for a a list of video entities
  class CategoryList
    def initialize(categories)
      @categories = categories.map.with_index { |category, i| CategoryInfo.new(category, i) }
    end

    def each(&)
      @categories.each(&)
    end

    def any?
      @categories.any?
    end

    def first
      @categories.first
    end
  end
end
