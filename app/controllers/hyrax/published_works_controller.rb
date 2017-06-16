# Generated via
#  `rails generate hyrax:work PublishedWork`

module Hyrax
  class PublishedWorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyku::IIIFManifest
    self.curation_concern_type = ::PublishedWork
    self.show_presenter = PublishedWorksPresenter
  end
end
