module Importer
  # Import an Eprints3 json file.
  module Eprints
    class JsonImporter
      def initialize(metadata_file, files_directory, dryrun = false)
        @model = 'Object'
        @files_directory = files_directory
        @metadata_file = metadata_file
        @dryrun = dryrun
        @files = []
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
            @files = attributes[:files] if attributes[:files].present?
            other_files = attributes[:other_files] if attributes[:other_files].present?
            attributes.delete(:other_files)
            @model = attributes[:model]
            attributes.delete(:model)
            #create_fedora_objects(attributes)
            update_with_other_files(attributes[:id], other_files)
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
      # @param [Hash] the object attributes
      def create_fedora_objects(attributes)
        puts 'Creating Fedora objects ... '
        @files ||= attributes[:files]
        @directory = @files_directory if @directory.blank?
        attributes.delete(:files)
        Factory.for(@model).new(attributes, @directory, @files).run
      end

      # Update the new Fedora object with the extracted text and thumbnail from eprints
      #
      # @param [String] the new object id
      # @param [Hash] the filenames of the files to use for the update
      def update_with_other_files(id, other_files)
        puts 'Updating with other files ... '
        main = ActiveFedora::Base.find(id)
        main.members.each do |fileset|
          unless other_files[fileset.title[0]].blank?
            other_files[fileset.title[0]].each do | file_to_add |
              begin
                # add -XX:+UseG1GC to Java options to avoid 500 errors
                path = File.join(@directory, file_to_add[:filename])
                IngestFileJob.send(:perform_now, fileset, path, Hyrax.config.batch_user_key, {relation: file_to_add[:type], update_existing: true, versioning: false})
              rescue
                Rails.logger.error "Failed to add #{file_to_add[:filename]}: #{$ERROR_INFO}"
              end
            end
          end
        end
      end

    end
  end
end
