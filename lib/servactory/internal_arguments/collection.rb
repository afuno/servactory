# frozen_string_literal: true

module Servactory
  module InternalArguments
    class Collection
      # NOTE: http://words.steveklabnik.com/beware-subclassing-ruby-core-classes
      extend Forwardable
      def_delegators :@collection, :<<, :each, :map

      def initialize(*)
        @collection = []
      end

      def names
        map(&:name)
      end
    end
  end
end