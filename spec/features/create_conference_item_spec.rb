# Generated via
#  `rails generate hyrax:work ConferenceItem`
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a ConferenceItem', js: true do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"
      choose "payload_concern", option: "ConferenceItem"
      click_button "Create work"
    end
  end
end
