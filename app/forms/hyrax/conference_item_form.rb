# Generated via
#  `rails generate hyrax:work ConferenceItem`
module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    self.model_class = ::ConferenceItem
    self.terms += [:resource_type]

    # remove things with
    self.terms -= [:based_near, :date_created, :source, :description]

    # use + to replace the whole set of terms
    # this defines form order
    self.terms += [:editor,
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
                   :origin_date,
                   :proceeding,
                   :presented_at,
                   :note
    ]
  end
end
