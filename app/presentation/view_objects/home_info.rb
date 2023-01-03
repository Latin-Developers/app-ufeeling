# frozen_string_literal: true

require_relative 'category_list'
require_relative 'video_list'

module Views
  # View for a a list of video entities
  class HomeInfo
    def initialize(viewed_videos, categories, videos_by_categories, category_selected)
      @viewed_videos = VideoList.new(viewed_videos)
      @videos_by_categories = VideoList.new(videos_by_categories)
      @categories = CategoryList.new(categories)
      @category_selected = category_selected
    end

    attr_reader :viewed_videos, :videos_by_categories, :categories, :category_selected
  end
end
