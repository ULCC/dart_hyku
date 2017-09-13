# Generated via
#  `rails generate hyrax:work PublishedWork`
require 'rails_helper'

RSpec.describe Hyrax::Actors::SharedActor do
  let(:ability) { ::Ability.new(depositor) }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:depositor) { create(:user) }
  let(:work) { create(:published_work) }

  let(:attributes) { {title: ['Foo Bar', ''], refereed: ""} }
  let(:terminator) {Hyrax::Actors::Terminator.new}

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  it "removes blank single-valued attributes" do
    middleware.create(env)
    expect(work.refereed).to eq(nil)
  end

  it "removes blank multi-valued attributes" do
    middleware.create(env)
    expect(work.title).to eq(['Foo Bar'])
  end

end
