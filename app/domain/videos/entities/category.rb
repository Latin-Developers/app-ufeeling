# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module UFeeling
  module Videos
    module Entity
      # Provides access to category data
      class Category < Dry::Struct
        include Dry.Types

        attribute :id,        Coercible::Integer.optional
        attribute :origin_id, Strict::String
        attribute :title,     Strict::String

        def to_attr_hash
          to_hash.except(:id)
        end
      end
    end
  end
end
