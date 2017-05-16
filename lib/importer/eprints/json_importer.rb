module Importer
  # Import an Eprints3 json file.
  module Eprints
    class JsonImporter
      def initialize(metadata_file, files_directory, dryrun = false)
        @model = 'Object'
        @files_directory = files_directory # unused
        @metadata_file = metadata_file
        @dryrun = dryrun
        @files = [] # don't send any files
      end

      def import_all
        count = 0
        if @dryrun == true
          analyser.each do |_attributes|
            # TODO
          end
        else
          parser.each do |attributes|
            @model = attributes[:model]
            attributes.delete(:model)
            attributes[:edit_groups] = ['admin']
            create_fedora_objects(attributes)
            add_to_work_filesets(attributes[:id], attributes.delete(:files_hash))
            count += 1
          end
        end
        count
      end

      private

        # Create a parser object with the metadata file
        def parser
          Eprints::JsonParser.new(@metadata_file)
        end

        # Create an analyser file with the metadata file and files directory
        def analyser
          []
          # EP3JsonAnalyser.new(@metadata_file, @files_directory)
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
          Eprints::JsonFilesProcessor.new(work, files_hash)
        end
    end
  end
end
