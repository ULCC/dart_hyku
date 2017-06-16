# Generated via
#  `rails generate hyrax:work Book`

module Hyrax
  class BooksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyku::IIIFManifest
    self.curation_concern_type = ::Book
    # Use this line if you want to use a custom presenter
    self.show_presenter = BookPresenter
  end
end
