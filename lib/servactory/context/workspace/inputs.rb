# frozen_string_literal: true

module Servactory
  module Context
    module Workspace
      class Inputs
        def initialize(context:, incoming_arguments:, collection_of_inputs:)
          @context = context
          @incoming_arguments = incoming_arguments
          @collection_of_inputs = collection_of_inputs
        end

        def method_missing(name, *args, &block)
          if name.to_s.end_with?("=")
            super
          else
            getter_with(name: name) { super }
          end
        end

        def respond_to_missing?(name, *)
          @collection_of_inputs.names.include?(name) || super
        end

        private

        def getter_with(name:, &block) # rubocop:disable Metrics/MethodLength, Lint/UnusedMethodArgument, Metrics/AbcSize
          input_name = name.to_s.chomp("?").to_sym
          input = @collection_of_inputs.find_by(name: input_name)

          return yield if input.nil?

          input_value = @incoming_arguments.fetch(input.name, nil)
          input_value = input.default if input.optional? && input_value.blank?

          input_prepare = input.prepare.fetch(:in, nil)
          input_value = input_prepare.call(value: input_value) if input_prepare.present?

          if name.to_s.end_with?("?")
            Servactory::Utils.query_attribute(input_value)
          else
            input_value
          end
        end
      end
    end
  end
end
