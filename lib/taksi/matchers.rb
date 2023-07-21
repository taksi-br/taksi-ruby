# frozen_string_literal: true

require 'taksi/matchers/have_component'

module Taksi
  module Matchers
    def have_component(*args)
      HaveComponent.new(*args)
    end
  end
end
