module Importer
  module Eprints
    class JsonParser
      include Enumerable
      include Eprints::JsonMapper
      include Eprints::JsonDownloader

      def initialize(file_name, directory)
        @file_name = file_name
        @directory = directory
      end

      # @yieldparam attributes [Hash] the attributes from one eprint
      def each(&_block)
        JSON.parse(File.read(@file_name)).each do |eprint|
          yield(attributes(eprint))
        end
      end

      private

        # Build the attributes for passing to Fedora

        # @param eprint [Hash] json for a single eprint
        # @return [Hash] attributes
        def attributes(eprint)
          attributes = standard_attributes(eprint)
          attributes = special_attributes(eprint, attributes)
          attributes[:model] = find_model(eprint['type'])
          attributes[:file_path] = download(eprint)
          attributes
        end

        # Build the standard attributes (those that can be called with just the name and value)

        # @param eprint [Hash] json for a single eprint
        # @param attributes [Hash] attributes hash
        # @return [Hash] attributes
        def standard_attributes(eprint)
          attributes = {}
          eprint.each do |k, v|
            next if ignored.include?(k) || special.include?(k)
            begin
              attributes = method(k).call(v, attributes)
            rescue
              Rails.logger.warn "No method for field #{k} (#{$ERROR_INFO.message})"
            end
          end
          attributes
        end

        # Build the special attributes (those that cannot be called with just the name and value)

        # @param eprint [Hash] json for a single eprint
        # @param [Hash] attributes hash
        # @return [Hash] attributes
        def special_attributes(eprint, attributes)
          if !eprint['event_title'].blank? and !eprint['event_type'].blank?
            attributes.merge!(event_title(eprint['event_title'], eprint['event_type']))
          elsif !eprint['event_title'].blank? and eprint['event_type'].blank?
            attributes.merge!(event_title(eprint['event_title']))
          end
          attributes.merge!(date(eprint['date'], eprint['date_type']))
          attributes.merge!(access_setting(eprint['metadata_visibility'], eprint['eprint_status']))
          attributes
        end

        # Determine the model for each eprint 'type'
        #
        # @param [String] the eprint 'type'
        # @return [String] the Model name
        def find_model(type)
          case type
          when 'kfpub'
            'PublishedWork'
          when 'monograph'
            'PublishedWork'
          else
            type.camelize
          end
        end
    end
  end
end
