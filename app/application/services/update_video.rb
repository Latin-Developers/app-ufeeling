# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class UpdateVideo
      include Dry::Transaction

      step :request_update

      private

      def request_update(input)
        result = UFeeling::Gateway::Api.new(UFeeling::App.config)
          .update_video(input[:video_id])

        result.success? ? Success(input) : Failure(result.message)
      rescue StandardError
        Failure('Could not update video')
      end
    end
  end
end
