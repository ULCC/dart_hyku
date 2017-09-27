# Generated via
#  `rails generate hyrax:work PublishedWork`
module Hyrax
  class PublishedWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::PublishedWork
    self.terms += [:resource_type, :rendering_ids]

    def secondary_terms
      super - [:rendering_ids]
    end

    # remove things with
    self.terms -= [:based_near, :date_created, :source, :description]

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
                   :place_of_publication,
                   :note
    ]
  end
end
