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
    end

    def import_all
      count = 0
      parser.each do | row |
        begin
          obj = ActiveFedora::Base.find(row[0])
          @model = obj.class
          attributes = { id: row[0], uploaded_files: row[1] }
          create_fedora_objects(attributes)
        rescue
          $stderr.puts("\nSomething went wrong with #{row[0]} - skipping this line - check logs for details")
          Rails.logger.warn "Something went wrong with #{row[0]} (#{$ERROR_INFO.message})"
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
        Factory.for(@model).new(attributes).run
      end

  end
end
