module Importer
  module Eprints
    class JsonAnalyser
      include Enumerable
      include Eprints::Mapper

      def initialize(file_name)
        @file_name = file_name
      end

      # @yieldparam attributes [Hash] the attributes from one eprint record
      def each(&_block)
        JSON.parse(File.read(@file_name)).each do |record|
          @model = find_model(record['type'])
          yield(attributes(record))
        end
      end

      private

        def attributes(_record)
          {}.tap do
          end
        end
    end
  end
end
