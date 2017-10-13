# frozen_string_literal: true

# load dog_biscuits config
DOGBISCUITS = YAML.safe_load(File.read(File.expand_path('../../dog_biscuits.yml', __FILE__))).with_indifferent_access
# include Terms
Qa::Authorities::Local.register_subauthority('subjects', 'DogBiscuits::Terms::SubjectsTerms')
Qa::Authorities::Local.register_subauthority('projects', 'DogBiscuits::Terms::ProjectsTerms')
Qa::Authorities::Local.register_subauthority('organisations', 'DogBiscuits::Terms::OrganisationsTerms')
Qa::Authorities::Local.register_subauthority('places', 'DogBiscuits::Terms::PlacesTerms')
Qa::Authorities::Local.register_subauthority('people', 'DogBiscuits::Terms::PeopleTerms')
Qa::Authorities::Local.register_subauthority('groups', 'DogBiscuits::Terms::GroupsTerms')
Qa::Authorities::Local.register_subauthority('departments', 'DogBiscuits::Terms::DepartmentsTerms')

# Configuration
DogBiscuits.config do |config|

  # Configure the class for creator
  # config.creator_class = String
end
