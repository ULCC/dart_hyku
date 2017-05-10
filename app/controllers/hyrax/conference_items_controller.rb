# Generated via
#  `rails generate hyrax:work ConferenceItem`

module Hyrax
  class ConferenceItemsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ConferenceItem

    # Use this line if you want to use a custom presenter
    self.show_presenter = ConferenceItemPresenter
  end
end
