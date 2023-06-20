# frozen_string_literal: true

module Servactory
  module Context
    module Workspace
      class Internals
        def initialize(context, workbench:)
          @context = context
          @collection_of_internals = workbench.collection
        end

        def method_missing(name, *args, &block)
          if name.to_s.end_with?("=")
            setter_with(name: name, value: args.pop) { super }
          else
            getter_with(name: name) { super }
          end
        end

        def respond_to_missing?(name, *)
          @collection_of_internals.names.include?(name) || super
        end

        private

        def setter_with(name:, value:, &block) # rubocop:disable Lint/UnusedMethodArgument
          prepared_name = name.to_s.delete("=").to_sym

          return yield unless @collection_of_internals.names.include?(prepared_name)

          internal = @collection_of_internals.find_by(name: prepared_name)

          Servactory::Internals::Validations::Type.validate!(
            context: @context,
            internal: internal,
            value: value
          )

          @context.instance_variable_set(:"@#{internal.name}", value)
        end

        def getter_with(name:, &block) # rubocop:disable Lint/UnusedMethodArgument
          internal = @collection_of_internals.find_by(name: name)

          return yield if internal.nil?

          @context.instance_variable_get(:"@#{internal.name}")
        end
      end
    end
  end
end