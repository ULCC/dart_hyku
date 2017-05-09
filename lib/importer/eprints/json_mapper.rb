module Importer
  module Eprints
    module JsonMapper
      # Fields to ignore when processing an eprint json
      #
      # @return [Array] ignored fields
      def ignored
        [
          'lastmod',
          'uri',
          'status_changed',
          'rev_number',
          'datestamp',
          'dir',
          'source',
          'date_type',
          'userid'
        ]
      end

      # Fields that need special treatment when processing an eprint json
      #
      # @return [Array] special fields

      def special
        [
          'corp_creators',
          'creators',
          'alt_title',
          'date',
          'contributors',
          'editors',
          'full_text_status',
          'metadata_visibility',
          'eprint_status'
        ]
      end

      # Special fields

      # TODO: should this be a separate field?
      def alt_title(val, attributes)
        attributes[:title] << val
        attributes
      end

      def corp_creators(val, attributes)
        attributes[:creator] ||= []
        val.each do |corp|
          attributes[:creator] << corp
        end
        attributes
      end

      def creators(val, attributes)
        attributes[:creator] ||= []
        val.each do |cr|
          attributes[:creator] << make_name(cr)
        end
        attributes
      end

      def editors(val, attributes)
        attributes[:editor] ||= []
        val.each do |ed|
          attributes[:editor] << make_name(ed)
        end
        attributes
      end

      def contributors(val, attributes)
        attributes[:contributor] ||= []
        val.each do |co|
          attributes[:contributor] << make_name(co)
        end
        attributes
      end

      def access_setting(metadata_visibility, eprint_status)
        if metadata_visibility == 'show' && eprint_status == 'archive'
          { visibility: 'open' }
        else
          { visibility: 'restricted' }
        end
      end

      def date(val, type)
        case type
        when 'published'
          { date_published: val.to_s }
        else
          { date: val.to_s }
        end
      end

      # Standard fields

      def abstract(val)
        { abstract: [val] }
      end

      # TODO make this more legible
      def documents(val)
        files = []
        other_files = {}
        tmp_files_hash = {}
        val.collect { | id | tmp_files_hash[id['docid'].to_s] = id['main'] }

        val.each do |doc|
          unless doc['relation'].blank?
            version_types ||= doc['relation'].collect {| t | t['type'].gsub('http://eprints.org/relation/','') }
              if version_types.include?('isIndexCodesVersionOf')
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] ||= []
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] << { filename: doc['main'], type: 'extracted_text' }
              elsif version_types.include?('issmallThumbnailVersionOf')
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] ||= []
                other_files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]] << { filename: doc['main'], type: 'thumbnail' }
              end
          else
              files << doc['main']
          end
        end
        { files: files, other_files: other_files }
      end

      def edition(val)
        { edition: [val.to_s] }
      end

      # pad out the identifier to 9 chars to match noid structure
      def eprintid(val)
        identifier = "ep#{val}"
        identifier.sub!('ep', 'ep0') while identifier.length < 9
        { former_id: [val.to_s], id: identifier }
      end

      def event_title(_val)
        # TODO
        {}
      end

      def event_type(_val)
        # TODO
        {}
      end

      def isbn(val)
        { isbn: [val.to_s] }
      end

      def ispublished(val)
        # TODO: lookup
        { publication_status: val }
      end

      def keywords(val)
        { keyword: val.split(',').collect(&:strip) }
      end

      def note(val)
        # use a different note field
        { description: [val] }
      end

      def number(val)
        { issue_number: val.to_s }
      end

      def official_url(val)
        { official_url: [val] }
      end

      def pages(val)
        { pagination: val.to_s }
      end

      def part(val)
        { part: [val] }
      end

      def place_of_pub(val)
        { place_of_publication: [val] }
      end

      def pres_type(_val)
        # TODO
        {}
      end

      def publisher(val)
        { publisher: [val] }
      end

      def refereed(val)
        if val == 'TRUE'
          { refereed: true }
        else
          { refereed: false }
        end
      end

      def series(val)
        { series: [val.to_s] }
      end

      def subjects(val)
        { subject: [val.to_s] }
      end

      def title(val)
        { title: [val] }
      end

      def type(val)
        # TODO: lookup
        { resource_type: [val] }
      end

      def volume(val)
        { volume_number: val.to_s }
      end

      private

        def make_name(name)
          "#{name['name']['family']}, #{name['name']['given']}"
        end
    end
  end
end
