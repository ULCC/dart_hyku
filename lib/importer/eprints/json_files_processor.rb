module Importer
  module Eprints
    class JsonFilesProcessor
      # @param work [ActiveFedora::Base] the work
      # @param files_hash [Hash] info re files to add to work
      def initialize(work, files_hash)
        @work = work
        @files_hash = files_hash
        update_fileset
      end

      # Update fileset
      def update_fileset
        @work.members.each do |fileset|
          if fileset.label.ends_with?('.txt')
            update_visibility(fileset, 'restricted') # KFSPECIFIC - txt should not be visible
          else
            update_work(fileset) # KFSPECIFIC - this will be the PDF
            update_visibility(fileset, @files_hash[fileset.label][:visibility])
          end
          # KFSPECIFIC - ensure indexcodes.txt is added to PDF
          next if @files_hash[fileset.label.gsub('.pdf', '.txt')][:additional_files].blank?
          update_with_other_files(
            fileset,
            @files_hash[fileset.label.gsub('.pdf', '.txt')][:additional_files]
          )
        end
      end

      protected

        # Update fileset visibility
        #
        # @param fileset [FileSet] fileset to update
        # @param visibility [String] the fileset visibility
        def update_visibility(fileset, visibility)
          fileset.visibility = visibility unless fileset.visibility == visibility
          fileset.save unless fileset.visibility == visibility
        end

        # Update the work to ensure it uses the thumbnail / representative from the primary fileset
        #
        # @param fileset [FileSet] primary fileset
        def update_work(fileset)
          # KFSPECIFIC - we want the object to derive it's thumbnail / representative from the pdf
          @work.representative = fileset
          @work.thumbnail = fileset
          @work.save
        end

        # Update the new Fedora object with the extracted text and thumbnail from eprints
        #
        # @param [String] the new object id
        # @param [Hash] the filenames of the files to use for the update
        def update_with_other_files(fileset, additional_files)
          additional_files.each do |file_to_add|
            file = download_remote_file(file_to_add[:url], file_to_add[:file_name])
            ingest_file(fileset, file.path, file_to_add[:type])
          end
        end

        # Ingest the file
        #
        # @param fileset [FileSet] the fileset object to add the file to
        # @param path [String] the file path
        # @param type [String] the 'type' of file
        def ingest_file(fileset, path, type)
          # This will not add anything to the text file; results in binary store / timeout error
          #   added -XX:+UseG1GC to Java options to avoid 500 errors (@escowles suggestion); made no difference
          #   same file will add to PDF, not txt
          IngestFileJob.send(:perform_later,
                             fileset, path,
                             Hyrax.config.batch_user_key,
                             relation: type,
                             update_existing: true,
                             versioning: false)
        rescue
          Rails.logger.error "Failed to add #{path}: #{$ERROR_INFO}"
        end

        # Download the file from the URL as a Tempfile
        #
        # @param url [String] the URL to download
        # @param file_name [String] the file_name to use for the tempfile
        # @return [Tempfile]
        def download_remote_file(url, file_name)
          file_name_parts = file_name.split('.')
          f = Tempfile.new([file_name_parts.first, ".#{file_name_parts.last}"])
          f.binmode
          spec = { 'url' => url }
          retriever = BrowseEverything::Retriever.new
          retriever.retrieve(spec) do |chunk|
            f.write(chunk)
          end
          f
        end
    end
  end
end
