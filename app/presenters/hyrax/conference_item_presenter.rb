# Generated via
#  `rails generate hyrax:work ConferenceItem`
module Hyrax
  class ConferenceItemPresenter < Hyku::ManifestEnabledWorkShowPresenter
    delegate :abstract, :date_published, :date_available, :date_accepted, :date_submitted, :editor, :isbn, :note, :official_url, :pagination, :place_of_publication, :publication_status, :presented_at, :proceeding, :refereed, :date, :doi, :former_identifier, :note, to: :solr_document
  end
end
