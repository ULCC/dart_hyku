# Generated via
#  `rails generate hyrax:work ConferenceItem`
module Hyrax
  module Actors
    class SharedActor < Hyrax::Actors::BaseActor

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        apply_singlevalued(env)
        super
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        apply_singlevalued(env)
        super
      end

      private

      def apply_singlevalued(env)
        env.curation_concern.attributes = remove_singlevalued!(env.attributes)
      end

      # If any singular attributes are empty strings, change to nil
      #   otherwise an empty property is stored in Fedora.
      # e.g.:
      #   self.attributes = { 'date_available' => '' }
      #   remove_singlevalued!
      #   self.attributes['date_available']
      # => nil
      def remove_singlevalued!(attributes)
        singlevalued_form_attributes(attributes).each do |k,v|
          attributes[k] = nil if v == ""
        end
        attributes
      end

      # Return the hash of attributes that are singlevalued
      def singlevalued_form_attributes(attributes)
        attributes.select { |_, v| v.is_a?(String) }
      end

    end
  end
end








