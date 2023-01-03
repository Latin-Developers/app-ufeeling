# frozen_string_literal: true

require 'dry/monads'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class HomePage
      include Dry::Transaction

      step :get_previous_videos
      step :format_previous_videos
      step :get_categories
      step :format_categories
      step :obtain_video_by_category
      step :format_previous_videos_by_category

      private

      def get_previous_videos(input)
        if input[:video_ids].size.zero?
          input[:videos_json] = '{"videos": []}'
          Success(input)
        else
          UFeeling::Gateway::Api.new(UFeeling::App.config).video_list(input[:video_ids], [])
            .then do |result|
              input[:videos_json] = result.payload
              result.success? ? Success(input) : Failure(result.message)
            end
        end
      rescue StandardError
        Failure('Could not access the API')
      end

      def format_previous_videos(input)
        Representer::VideosList.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
          .from_json(input[:videos_json])
          .then do |videos|
            input[:videos] = videos
            Success(input)
          end
      rescue StandardError
        Failure('Could not parse response from API')
      end

      def get_categories(input)
        UFeeling::Gateway::Api.new(UFeeling::App.config).category_list
          .then do |result|
            input[:categories_json] = result.payload
            result.success? ? Success(input) : Failure(result.message)
          end
      rescue StandardError
        Failure('Could not access our API')
      end

      def format_categories(input)
        Representer::CategoriesList.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
          .from_json(input[:categories_json])
          .then do |categories|
            input[:categories] = categories
            Success(input)
          end
      rescue StandardError
        Failure('Could not parse response from API')
      end

      def obtain_video_by_category(input)
        if input[:category_selected]
          UFeeling::Gateway::Api.new(UFeeling::App.config).video_list([], [input[:category_selected]])
            .then do |result|
              input[:videos_by_category_json] = result.payload
              result.success? ? Success(input) : Failure(result.message)
            end
        else
          input[:videos_by_category_json] = '{"videos": []}'
          Success(input)
        end
      rescue StandardError
        Failure('Could not access the API')
      end

      def format_previous_videos_by_category(input)
        Representer::VideosList.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
          .from_json(input[:videos_by_category_json])
          .then do |videos_by_category|
            input[:videos_by_category] = videos_by_category
            Success(input)
          end
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end
