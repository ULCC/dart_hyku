class ConferenceItemsPresenter < Hyrax::WorkShowPresenter

  # these correspond to the method names in solr_document.rb
  delegate :isbn,
           :editor,
           :pagination,
           :date_published,
           :date_available,
           :date_accepted,
           :date_submitted,
           :abstract,
           :official_url,
           :publication_status,
           :refereed,
           :place_of_publication,
           :proceeding,
           :origin_date,
           :presented_at,
           to: :solr_document
end