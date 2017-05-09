module Importer
  module Factory
    class PublishedWorkFactory < ObjectFactory
      self.klass = PublishedWork
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'Image')
      # end
    end
  end
end
