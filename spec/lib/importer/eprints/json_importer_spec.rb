require 'importer'
require 'importer/eprints'

RSpec.describe Importer::Eprints::JsonImporter do
  let(:files_directory) {'spec/fixtures/eprints_json/files'}
  let(:metadata_file) {'spec/fixtures/eprints_json/eprints.json'}
  let(:importer) {described_class.new(metadata_file, files_directory)}
  let(:actor) {double}
  let(:published_work_factory) { double }
  before do
    allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
  end

  it 'creates an object' do
    stub_request(:get, /.*/).
        to_return(status: 200, body: "", headers: {})

    expect(importer).to receive(:create_fedora_objects).exactly(1).times
    importer.import_all
  end

  it 'uses the published item factory, ie. the model is correctly set' do
    expect(Importer::Factory::PublishedWorkFactory).to receive(:new)
                                                 .with(hash_excluding(:model), "#{files_directory}/6289", array_including('006289.pdf'), )
                                                 .and_return(published_work_factory)
    expect(published_work_factory).to receive(:run)
    importer.import_all
  end

  # TODO test the update files method
end
