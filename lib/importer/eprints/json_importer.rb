module Importer
  # Import an Eprints3 json file.
  module Eprints
    class JsonImporter
      def initialize(metadata_file, files_directory, dryrun = false)
        @model = 'Object'
        @files_directory = files_directory
        @metadata_file = metadata_file
        @dryrun = dryrun
        @files = [] # we do files as a separate step, so send an empty array
      end

      def import_all
        count = 0
        if @dryrun == true
          puts 'Analysing ... '
          analyser.each do |_attributes|
            # could just not do the create and update steps, and return something!
            puts 'not doing anything'
          end
        else
          parser.each do |attributes|
            @directory = attributes[:file_path]
            attributes.delete(:file_path)
            filesets = attributes[:files_hash]
            @files = attributes[:files]
            attributes.delete(:files_hash)
            # other_files = attributes[:other_files] if attributes[:other_files].present?
            # attributes.delete(:other_files)
            @model = attributes[:model]
            attributes.delete(:model)
            attributes[:edit_groups] = ['admin']
            create_fedora_objects(attributes)
            add_filesets_to_work(attributes[:id], filesets)
            count += 1
          end
        end
        count
      end

      private

        # Create a parser object with the metadata file and files directory
        def parser
          Eprints::JsonParser.new(@metadata_file, @files_directory)
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
          puts 'Creating Fedora objects ... '
          attributes.delete(:files)
          Factory.for(@model).new(attributes, @directory, @files).run
        end

        # Add filesets to the work
        #
        # @param id [String] id of the work
        # @param files_hash [Hash] info re files to add to work
        def add_filesets_to_work(id, files_hash)
          puts 'Adding filesets ... '
          work = ActiveFedora::Base.find(id)
          Eprints::JsonFilesProcessor.new(work, files_hash, @directory)
        end
    end
  end
end
