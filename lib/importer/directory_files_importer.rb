module Importer
  # Update existing works with files via csv file with one work per row.
  #  The CSV should not contain a header row.
  #  The first column must be the work id.
  #  The second column must be the directory containing the files OR the filename itself.
  class DirectoryFilesImporter
    # depth 0 = files in the specified directory
    # depth 1+ = files in the nth directory,
    #  1 = files_directory/directory_from_csv/files
    #  2 = files_directory/directory_from_csv/another_directory/files
    def initialize(metadata_file, files_directory, depth)
      @files_directory = files_directory.chomp('/')
      @metadata_file = metadata_file
      @depth = depth
      @Model = 'Object' # Updating existing objects, so no need to set model
    end

    def import_all
      count = 0
      parser.each do | row |
        begin
          puts row
          obj = ActiveFedora::Base.find(row[0])
          attributes = obj.attributes
          attributes['files'] = row[1]
          create_fedora_objects(attributes)
        rescue
          "\nObject with id #{row[0]} was not found - skipping this line"
          Rails.logger.warn "Object with id #{row[0]} was not found (#{$ERROR_INFO.message})"
        end
        count += 1
      end
      count
    end

    private

      def parser
        FilesParser.new(@metadata_file, @files_directory, @depth)
      end

      # Build a factory to create the objects in fedora.
      def create_fedora_objects(attributes)
        Factory.for(model).new(attributes, @files_directory).run
      end
  end
end
