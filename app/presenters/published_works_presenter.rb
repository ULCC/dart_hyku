class PublishedWorksPresenter < Hyrax::WorkShowPresenter

  # these correspond to the method names in solr_document.rb
  delegate :isbn,
           :editor,
           :volume_number,
           :issue_number,
           :pagination,
           :date_published,
           :date_available,
           :date_accepted,
           :date_submitted,
           :abstract,
           :official_url,
           :publication_status,
           :refereed,
           :part,
           :edition,
           :series,
           :place_of_publication,
           to: :solr_document
end