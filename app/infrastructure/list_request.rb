# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module UFeeling
  module Gateway
    module Value
      # List request parser
      class WatchedList
        include Dry::Monads::Result::Mixin

        # Use in client App to create params to send
        def self.to_encoded(data)
          Base64.urlsafe_encode64(data.to_json)
        end
      end
    end
  end
end
