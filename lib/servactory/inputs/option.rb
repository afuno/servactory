# frozen_string_literal: true

module Servactory
  module Inputs
    class Option
      DEFAULT_VALUE = ->(key:, value:, message: nil) { { key => value, message: message } }

      private_constant :DEFAULT_VALUE

      attr_reader :name,
                  :validation_class,
                  :define_input_methods,
                  :define_input_conflicts,
                  :need_for_checks,
                  :value_key,
                  :value

      # rubocop:disable Metrics/MethodLength
      def initialize(
        name:,
        input:,
        validation_class:,
        need_for_checks:,
        value_fallback:,
        original_value: nil,
        value_key: nil,
        define_input_methods: nil,
        define_input_conflicts: nil,
        with_advanced_mode: true,
        **options
      ) # do
        @name = name.to_sym
        @validation_class = validation_class
        @define_input_methods = define_input_methods
        @define_input_conflicts = define_input_conflicts
        @need_for_checks = need_for_checks
        @value_key = value_key

        @value = prepare_value_for(
          original_value: original_value,
          options: options,
          value_fallback: value_fallback,
          with_advanced_mode: with_advanced_mode
        )

        prepare_input_methods_for(input)
      end
      # rubocop:enable Metrics/MethodLength

      def need_for_checks?
        need_for_checks
      end

      private

      def prepare_value_for(original_value:, options:, value_fallback:, with_advanced_mode:)
        return original_value if original_value.present?

        return options.fetch(@name, value_fallback) unless with_advanced_mode

        prepare_advanced_for(
          value: options.fetch(@name, DEFAULT_VALUE.call(key: value_key, value: value_fallback)),
          value_fallback: value_fallback
        )
      end

      def prepare_advanced_for(value:, value_fallback:)
        if value.is_a?(Hash)
          message = value.fetch(:message, nil)

          DEFAULT_VALUE.call(
            key: value_key,
            value: value.fetch(value_key, message.present? ? true : value_fallback),
            message: message
          )
        else
          DEFAULT_VALUE.call(key: value_key, value: value)
        end
      end

      def prepare_input_methods_for(input)
        input.instance_eval(define_input_methods_template) if define_input_methods_template.present?
      end

      def define_input_methods_template
        return if @define_input_methods.blank?

        @define_input_methods_template ||= @define_input_methods.map do |define_input_method|
          <<-RUBY
            def #{define_input_method.name}
              #{define_input_method.content.call(value: @value)}
            end
          RUBY
        end.join("\n")
      end
    end
  end
end
