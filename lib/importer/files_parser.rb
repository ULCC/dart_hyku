module Importer
  class FilesParser
    include Enumerable

    def initialize(metadata_file, files_directory, depth)
      @file_name = metadata_file
      @directory = files_directory
      @depth = depth
    end

    # @yieldparam attributes [Hash] the attributes from one row of the file
    def each(&_block)
      CSV.foreach(@file_name) do |row|
        [row[0],build_files_hash(row[1])]
      end
    end

    private

      def build_files_hash(directory_or_file)
        if @depth == 0
          file = File.join(@directory, directory_or_file)
          return [] unless check_file(file)
          [directory_or_file]
        elsif depth > 0
          dir = File.join(@directory,directory_or_file)
          return [] unless check_dir(dir)
          [build_file_path(dir)]
        end
      end

      def build_file_path(path)
        i = @depth
        while i > 0
          path = "#{path}/*"
          i -= 1
        end
        # Reject directories at this point
        Dir.glob(path).reject{ |e| File.directory? e }.sub("#{@directory}/",'')
      end

      def check_file(path)
        File.file?(path)
      end

      def check_dir(path)
        File.directory?(path)
      end
  end
end
