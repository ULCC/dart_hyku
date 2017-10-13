# Generated via
#  `rails generate hyrax:work ConferenceItem`
module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    self.model_class = ::ConferenceItem
    self.terms += [:resource_type]
    self.terms += [:rendering_ids]
    def secondary_terms
      super - [:rendering_ids]
    end
  end
end
