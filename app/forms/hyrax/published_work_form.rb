# Generated via
#  `rails generate hyrax:work PublishedWork`
module Hyrax
  class PublishedWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::PublishedWork
    self.terms += [:resource_type]

    # remove things with
    self.terms -= [:based_near, :date_created, :source]

    # use + to replace the whole set of terms
    # this defines form order
    self.terms += [:isbn,
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
                   :place_of_publication
    ]
  end
end
