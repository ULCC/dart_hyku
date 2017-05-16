require 'importer'
require 'importer/eprints'

RSpec.describe Importer::Eprints::JsonFilesProcessor do
  let(:processor) { described_class.new(work, files_hash) }
  let(:work) { PublishedWork.new }
  let(:fileset) { FileSet.new(label: '006289.pdf') }
  let(:files_hash) {
    {"006289.txt"=>
         {:additional_files=>[
             {:file_name=>"indexcodes.txt",
              :url=>"http://archive.kingsfund.org.uk/6289/3/indexcodes.txt",
              :type=>"extracted_text"}]},
     "006289.pdf"=>{}}
  }

  before do
    work.members << fileset
  end
  
  it 'all the receives' do
    stub_request(:get, "http://archive.kingsfund.org.uk/6289/3/indexcodes.txt").
        to_return(status: 200, body: "here is some content", headers: {})
    expect(Hyrax::IngestFileJob).to receive(:send).exactly(2).times
    processor.update_fileset
  end
end
