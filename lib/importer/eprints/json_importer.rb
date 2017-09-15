module Importer
  # Import an Eprints3 json file.
  module Eprints
    class JsonImporter
      def initialize(metadata_file)
        @model = 'Object'
        @metadata_file = metadata_file
        @files = [] # don't send any files
      end

      # Import the items
      #
      # @return count of items imported
      def import_all
        count = 0
        ids = []
          parser.each do |attributes|
            @model = attributes[:model]
            attributes.delete(:model)
            # TEMP
            attributes.delete(:remote_files)
            # TEMP END
            attributes[:edit_groups] = ['admin']
            create_fedora_objects(attributes)
            #ids << { attributes[:id] => attributes.delete(:files_hash) }
            add_to_collection(attributes[:id])
            count += 1
          end
          # Update filesets with extracted_text
          #   do this as a separate step to allow jobs to complete
          ids.each do |work|
            id = work.keys.first
            add_to_work_filesets(id, work[id])
          end

        count
      end

      private

        # Create a parser object with the metadata file
        def parser
          Eprints::JsonParser.new(@metadata_file)
        end

        # Build a factory to create the objects in fedora.
        #
        # @param attributes [Hash] the object attributes
        def create_fedora_objects(attributes)
          Factory.for(@model).new(attributes).run
        end

        # Add to filesets for the work
        #
        # @param id [String] id of the work
        # @param files_hash [Hash] info about files to add to work
        def add_to_work_filesets(id, files_hash)
          work = ActiveFedora::Base.find(id)
          file_processor = Eprints::JsonFilesProcessor.new(work, files_hash)
          file_processor.update_fileset
        end
      #TEMP!!!
      def add_to_collection(id)
        work = ActiveFedora::Base.find(id)
        collections = work.member_of_collections
        collections << ActiveFedora::Base.find('190de7b8-86d4-41be-ad8f-6fd7e51231e3')# 'b81cd60c-5726-4309-925e-b8d32f4fe79e'
        work.member_of_collections = collections
        work.save
      end

    end
  end
end
