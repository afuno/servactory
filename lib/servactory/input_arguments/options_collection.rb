# frozen_string_literal: true

module Servactory
  module InputArguments
    class OptionsCollection
      # NOTE: http://words.steveklabnik.com/beware-subclassing-ruby-core-classes
      extend Forwardable
      def_delegators :@collection, :<<, :each, :select, :map

      def initialize(*)
        @collection = []
      end

      def check_classes
        select { |option| option.check_class.present? }.map(&:check_class).uniq
      end

      def options_for_checks
        select(&:need_for_checks?).to_h do |option|
          value = if option.value.is_a?(Hash)
                    option.value.key?(:is) ? option.value.fetch(:is) : option.value
                  else
                    option.value
                  end

          [option.name, value]
        end
      end
    end
  end
end