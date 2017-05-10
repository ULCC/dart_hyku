# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookForm < Hyrax::Forms::WorkForm
    self.model_class = ::Book
    self.terms += [:resource_type]

    # remove things with
    self.terms -= [:based_near]

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
