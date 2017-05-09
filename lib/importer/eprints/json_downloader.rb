module Importer
  module Eprints
    module JsonDownloader
      include Enumerable

      require 'faraday'

      # TODO: some robistification required, eg. https://gist.github.com/janko-m/7cd94b8b4dd113c2c193
      # Download each file listed in hash['documents']
      #
      # @param eprint [Hash] a hash of the eprint metadata
      # @return [String] the directory containing the downloaded files
      def download(eprint)
        dir = make_eprint_directory(eprint['eprintid'])
        eprint['documents'].each do |doc|
          download_url = setup_download_url(doc)
          path = setup_download_path(dir, download_url)
          next if File.exist? path
          do_download(download_url, path)
        end
        dir
      end

      private

        # Construct the download url from the document hash
        #
        # @param document [Hash] the eprint document
        # @return [String] download url
        def setup_download_url(document)
          # TODO: fetch the url from the document
          "http://archive.kingsfund.org.uk/#{document['eprintid']}/#{document['pos']}/#{document['main']}"
        end

        # Construct the path for the download
        #
        # @param dir [String] the directory
        # @param download [String] the download url
        # @return [String] the download path (including filename to write)
        def setup_download_path(dir, download)
          "#{dir}/#{download.to_s.split('/')[-1]}"
        end

        # Do the download
        #
        # @param download [String] the uri to download
        # @param path [String] the download path
        def do_download(download, path)
          puts path
          Rails.logger.info "Downloading #{download}"
          response = Faraday.get download
          # replace unreadable characters in ASCII 8BIT text files
          if response.body.encoding.to_s == 'ASCII-8BIT' and path.ends_with?('.txt')
            tmp_file = response.body.encode('UTF-8',
                                            { invalid: :replace,
                                             undef: :replace,
                                             replace: '?'} )
            new_file = File.open(path, 'wb')
            new_file.write(tmp_file)
          else
            File.open(path, 'wb') { |fp| fp.write(response.body) }
          end
        end

        # Create a directory for the downloaded files
        #
        # @param eprint_id [String or FixNum] the eprint id
        # @return [String] path to the new directory
        def make_eprint_directory(eprint_id)
          dir = File.join(@directory, eprint_id.to_s)
          Dir.mkdir(dir, 0o770) unless Dir.exist? dir
          dir
        end
    end
  end
end
