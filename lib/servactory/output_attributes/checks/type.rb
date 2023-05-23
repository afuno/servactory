# frozen_string_literal: true

module Servactory
  module OutputAttributes
    module Checks
      class Type < Base
        DEFAULT_MESSAGE = lambda do |service_class_name:, output_attribute:, expected_type:, given_type:|
          I18n.t(
            "servactory.output_attributes.checks.type.default_error",
            service_class_name: service_class_name,
            output_attribute_name: output_attribute.name,
            expected_type: expected_type,
            given_type: given_type
          )
        end

        private_constant :DEFAULT_MESSAGE

        def self.check!(...)
          new(...).check!
        end

        ##########################################################################

        def initialize(context:, output_attribute:, value:)
          super()

          @context = context
          @output_attribute = output_attribute
          @value = value
        end

        def check!
          return if prepared_types.any? { |type| @value.is_a?(type) }

          raise_error_with(
            DEFAULT_MESSAGE,
            service_class_name: @context.class.name,
            output_attribute: @output_attribute,
            expected_type: prepared_types.join(", "),
            given_type: @value.class.name
          )
        end

        private

        def prepared_types
          @prepared_types ||=
            Array(@output_attribute.types).map do |type|
              if type.is_a?(String)
                Object.const_get(type)
              else
                type
              end
            end
        end
      end
    end
  end
end