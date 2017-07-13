module Importer
  module Eprints
    extend ActiveSupport::Autoload
    autoload :JsonAnalyser
    autoload :JsonImporter
    autoload :JsonParser
    autoload :JsonMapper
    autoload :JsonFilesProcessor
  end
end
