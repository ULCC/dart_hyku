module Hyku
  # A controller mixin that provides an IIIF search action, which returns a
  # IIIF search result according to the search API
  module IIIFSearch
    extend ActiveSupport::Concern

    # Load the resource to access the curation_concern
    # If we don't include manifest, the manifest will be unauthorized
    included do
      skip_authorize_resource only: [:search,:manifest]
    end

    def search
      headers['Access-Control-Allow-Origin'] = '*'
      respond_to do |format|
        format.json { render json: search_service_response_builder }
      end
    end

    private

      # Build the the search results response
      #
      # @return [Hash] IIIF Search API compliant response
      def search_service_response_builder
        # TODO: without this, we don't get the presnter; I am unsure why
        @presenter = Hyku::ManifestEnabledWorkShowPresenter.new(
          SolrDocument.new(curation_concern.to_solr), current_ability, request)
        {
          '@context' => 'http://iiif.io/api/search/0/context.json',
          '@id' =>
            "#{presenter.manifest_url.gsub('manifest', 'search')}?q=#{sanitized_params}&motivation=painting",
          '@type' => 'sc:AnnotationList',
          'resources' => search_service_results_builder
        }
      end

      # Build the search results
      # Return an empty array if there is no query parameter
      # Return an empty array if there are no results from the da search endpoint
      #
      # @return [Array<Hash>] search results
      def search_service_results_builder
        results = []
        return results if params['q'].blank?
        query_result = da_iip_query
        return results if query_result.blank?
        query_result.each do |result|
          canvas = canvas_id_finder(result['index'])
          result['rects'].each_with_index do | rect, index |
            results << search_service_single_result(canvas, coordinates(rect)) unless canvas.nil?
          end
        end
        results
      end

      # Query the da search endpoint
      # The result will look like this:
      #  [
      #     {
      #       "index": "33",
      #       "rects": [
      #         {
      #           "y": 1119,
      #           "w": 157,
      #           "h": 19,
      #           "hit": 12,
      #           "x": 1030
      #         }
      #       ]
      #     },
      #    // more results ...
      #  ]
      #
      # @return [Hash] JSON response
      def da_iip_query
        pubid = pubid_finder
        return [] if pubid.blank?
        iip_url = "#{ENV['IIIF_SEARCH_ENDPOINT']}?pubid=#{pubid}&t=#{sanitized_params}"
        response = Faraday.get iip_url
        JSON.parse(response.body) if response.status == 200
      rescue StandardError
        logger.error("Error performing GET on #{iip_url}")
        []
      end

      # Build a single search result
      #
      # @param id [String] canvas (image) id
      # @param xywh [String] coordinates
      # @return [Hash] search result
      def search_service_single_result(id, xywh)
        {
          '@id' => "#{presenter.manifest_url.gsub('manifest', 'annotation')}/#{id}_#{xywh}",
          '@type' => 'oa:Annotation',
          'motivation' => 'sc:painting',
          'resource' => {
            '@type' => 'cnt:ContentAsText',
            # we don't get any text from the search so use the search term
            'chars' => sanitized_params
          },
          'on' => "#{presenter.manifest_url}/canvas/#{id}#xywh=#{xywh}"
        }
      end

      # Sanitized serach query
      #
      # @return [String] search query
      def sanitized_params
        ActionController::Base.helpers.sanitize(params['q'])
      end

      # The pubid is the biblionumber
      #
      # @return [String] pubid
      def pubid_finder
        presenter.biblionumber.first if presenter.respond_to?(:biblionumber)
      end

      # Get the canvas (FileSet) id from its postition in the member_presenters array
      # Add 1 because the PDF is at index 0
      # Skip if the canvas number is not present
      #
      # @param index [String] index position from the da search endpoint
      # @return [String] canvas (image) id
      def canvas_id_finder(index)
        presenter.member_presenters[index.to_i + 1].id unless presenter.member_presenters[index.to_i + 1].nil?
      end

      # XYWH Coordinates
      #
      # @param rects [Hash] coordinates hash
      # @return [String] x,y,w,h
      def coordinates(rects)
        "#{rects['x']},#{rects['y']},#{rects['w']},#{rects['h']}"
      end
  end
end
