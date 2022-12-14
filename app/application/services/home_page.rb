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
      # TODO: step :get_videos_by_category
      # TODO: step :format_videos_by_category

      private

      def get_previous_videos(input)
        if input[:video_ids].size.zero?
          Success('{"videos": []}')
        else
          UFeeling::Gateway::Api.new(UFeeling::App.config).video_list(input[:video_ids])
            .then do |result|
              result.success? ? Success(result.payload) : Failure(result.message)
            end
        end
      rescue StandardError
        Failure('Could not access our API')
      end

      def format_previous_videos(videos_json)
        Representer::VideosList.new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
          .from_json(videos_json)
          .then { |videos| Success(videos:) }
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
        Representer::CategoriesList.new(OpenStruct.new)
          .from_json(input[:categories_json])
          .then do |categories|
            input[:categories] = categories
            Success(input)
          end
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end
