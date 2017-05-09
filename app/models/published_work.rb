# Generated via
#  `rails generate hyrax:work PublishedWork`
class PublishedWork < ::DogBiscuits::PublishedWork # ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # include ::Hyrax::BasicMetadata

  self.indexer = PublishedWorkIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Published Item'

end
