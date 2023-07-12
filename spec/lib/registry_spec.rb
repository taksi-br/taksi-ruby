# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Taksi::Registry do
  subject { described_class.instance }

  describe '#add' do
    context 'with an invalid interface name' do
      it 'fails with error messsage' do
        expect { subject.add(Class, 'INVALID.NAME') }.to raise_error(StandardError, "Invalid interface name 'INVALID.NAME', it must to match regex '/^[a-z\\-\\_\\/]{1,80}$/i'")
      end
    end
  end

end
