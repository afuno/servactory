# frozen_string_literal: true

module Usual
  class Example28 < ApplicationService::Base
    configuration do
      shortcuts_for_make %i[assign]
    end

    output :number, type: Integer

    assign :number

    private

    def assign_number
      outputs.number = 7
    end
  end
end
