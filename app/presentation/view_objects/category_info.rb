# frozen_string_literal: true

module Views
  # View for a single video entity
  class CategoryInfo
    def initialize(category, index = nil)
      @category = category
      @index = index
    end

    attr_reader :category

    def origin_id
      @category[:origin_id]
    end

    def category_title
      @category[:title]
    end
  end
end
