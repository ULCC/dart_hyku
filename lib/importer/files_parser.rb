module Importer
  class FilesParser
    include Enumerable

    def initialize(metadata_file, files_directory, depth)
      @file_name = metadata_file
      @directory = files_directory
      @depth = depth.to_i
    end

    # @yieldparam attributes [Hash] the attributes from one row of the file
    def each(&_block)
      CSV.foreach(@file_name) do |row|
        yield [row[0],build_files_hash(row[1])]
      end
    end

    private

      def build_files_hash(directory_or_file)
        if @depth == 0
          file = File.join(@directory, directory_or_file)
          return [] unless check_file(file)
          build_files([file])
        elsif @depth > 0
          dir = File.join(@directory,directory_or_file)
          return [] unless check_dir(dir)
          build_files(build_file_path(dir))
        end
      end

      def build_file_path(path)
        i = @depth
        while i > 0
          path = "#{path}/*"
          i -= 1
        end
        # Reject directories at this point
        Dir.glob(path).reject{ |e| File.directory? e }
      end

      def build_files(files)
        files_array = []
        files.each do | file |
          u = Hyrax::UploadedFile.new
          u.user_id = User.find_by_user_key( User.batch_user_key ).id
          u.file = CarrierWave::SanitizedFile.new(file)
          u.save
          files_array <<  u.id
        end
        files_array
      end

      def check_file(path)
        File.file?(path)
      end

      def check_dir(path)
        File.directory?(path)
      end
  end
end
