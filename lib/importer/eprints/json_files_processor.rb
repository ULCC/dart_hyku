module Importer
  module Eprints
    class JsonFilesProcessor
      # @param work [ActiveFedora::Base] the work
      # @param files_hash [Hash] info re files to add to work
      def initialize(work, files_hash, directory)
        @directory = directory
        @work = work
        @files_hash = files_hash
        update_fileset
      end

      # Update fileset
      def update_fileset
        @work.members.each do |fileset|
          # KFSPECIFIC - txt should not be visible
          if fileset.title[0].ends_with?('.txt')
            update_visibility(fileset, 'restricted')
            # KFSPECIFIC - indexcodes won't add to txt so omit this step
            # update_with_other_files(fileset, @files_hash[fileset.title[0]][:additional_files])
          else
            # KFSPECIFIC - this will be the PDF
            update_work(fileset)
            update_visibility(fileset, @files_hash[fileset.title[0]][:visibility])
            update_with_other_files(fileset, @files_hash[fileset.title[0]][:additional_files])
          end
        end
      end

      # Update fileset visibility
      #
      # @param fileset [FileSet] fileset to update
      # @param visibility [String] the fileset visibility
      def update_visibility(fileset, visibility)
        unless fileset.visibility = visibility
          fileset.visibility = visibility
          fileset.save
        end
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
          path = File.join(@directory, file_to_add[:filename])
          ingest_file(fileset, path, file_to_add[:type])
        end unless additional_files.blank?
        # KFSPECIFIC - indexcodes won't add to txt so add it to the pdf
        ingest_file(fileset, File.join(@directory, 'indexcodes.txt'), 'extracted_text')
      end

      # Ingest the file
      #
      # @param fileset [FileSet] the fileset object to add the file to
      # @param path [String] the file path
      # @param type [String] the 'type' of file
      def ingest_file(fileset, path, type)
        # add -XX:+UseG1GC to Java options to avoid 500 errors
        # will not add anything to the text file;
        # established that it's not the file being added as it *will* add to the pdf
        IngestFileJob.send(:perform_now,
                           fileset, path,
                           Hyrax.config.batch_user_key,
                           relation: type,
                           update_existing: true,
                           versioning: false)
      rescue
        Rails.logger.error "Failed to add #{path}: #{$ERROR_INFO}"
      end
    end
  end
end
