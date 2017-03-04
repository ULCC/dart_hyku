# Much of this testing is the complex configurable stuff underneath UploadedFile
# and simulating the AWS configuration that would be in production.

# rubocop:disable Metrics/LineLength
RSpec.describe 'Hyrax::UploadedFile' do # rubocop:disable RSpec/DescribeClass
  let(:bigurl) { 'https://demo-application-w5twjcsuyx3v-uploadbucket-4l1zpvmp62nf.s3.amazonaws.com//var/app/current/tmp/uploads/hyrax/uploaded_file/file/31/image.png?X-Amz-Expires=600\u0026X-Amz-Date=20161214T193306Z\u0026X-Amz-Security-Token=FQoDYXdzEMT//////////wEaDMj3NLTbn4Y3JgbItSK3A57LyrcXBHQlP6lM7cT/2N9naRgRSef4EG/AxCCjMGcEVdt4X5ZsfHdzNiD6L0GODXmrP3quoXNBNZCoUVo3DY5E0P67iz9tYC2Ac%2BILJ%2BBzELNz84XI7C9zg6CCecZ8oeNjCTJXsMZ3xLx2bN099sl%2BY5nduDXAxen2Z63QKw7kiuuEXin/z%2B4ywFSP/Z1Sqbjkq4Qwjs5FUSyyz61wjl1%2Bg8uIJ5u3HTOlb8eZpk7gUCtdmLIE7mK1eZe5azUJC8XBW7Eu7jaRyM2PKMwjVnwepnfgPyEDqJSzKYJt1bGXgnQEN7logEKNOjmOcJqggM5Tc7PD40USAveIQ6E8ny/X0N%2BZ/X1rZTaCiAH1aWwVNqa0M43mlECrBeDv9I9BRMJzp4btvEgHKODrJe2MawDu4L1%2BzVNgOD7TZjrFt9zSEpyQK79dh8oHuyzDL0C%2Bpw3zL2ambsJ5OX6UnMuAmrkBbin1PKh2nHFkL/0xXAb2ZbSV6vKBxzKeQ62HMvv8UqypKbkwOMnstxyGGp00r6m6vL62x%2BTDergiiRfs947NyfJnP5l/rNRNMNesGo6kBmAqpACaBPAo0Z3GwgU%3D\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=ASIAIB72YBSAAINUZRPQ/20161214/us-east-1/s3/aws4_request\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=f9bfb2b8d6114bccb6e88e4c0526bf19c5658b587ee368d04b42b1881d5359db' }
  let(:file) { File.open(fixture_path + '/images/world.png') }
  let(:upload) { Hyrax::UploadedFile.create(file: file) }
  let(:config) { CarrierWave.configure { |c| c } }

  shared_examples 'Regular upload' do
    it 'mounts Uploader as expected' do
      expect(upload.file).to be_a Hyrax::UploadedFileUploader
      expect(upload.file).to be_a CarrierWave::Uploader::Base
    end
    it 'Gives clean filename and object' do
      expect(upload.file.filename).to eq 'world.png'
    end
  end

  describe CarrierWave::Support::UriFilename do
    it 'helper method can handle S3 URI' do
      expect(described_class.filename(bigurl)). to eq 'image.png'
    end
  end

  describe CarrierWave::SanitizedFile do
    let(:sfile) { CarrierWave::SanitizedFile.new(bigurl) }
    it 'cannot handle S3 URI' do
      # if the following trips, it means we *might* be able to use just carrierwave again, w/o carrierwave-aws
      expect(sfile.filename).not_to eq 'image.png'
    end
  end

  describe CarrierWave::Storage::File do
    it 'has default config' do
      expect(config.storage).to eq described_class # in dev/test
    end
    it_behaves_like 'Regular upload'
    it 'returns a SanitizedFile' do
      expect(upload.file.file).to be_a CarrierWave::SanitizedFile
    end
  end

  # AWSFile constuctor args look like:
  # uploader:
  #   <Hyrax::UploadedFileUploader:0x007fcae3312288
  #     @model=#<Hyrax::UploadedFile id: 3, file: "world.png", user_id: nil, file_set_uri: nil, created_at: "2017-03-02 21:51:45", updated_at: "2017-03-02 21:51:45">,
  #     @mounted_as=:file, @cache_id="1488491505-93525-0003-2232", @filename="world.png", @original_filename="world.png",
  #     @file=#<CarrierWave::SanitizedFile:0x007fcae4839ee0 @file="/Users/atz/repos/hyku/public/uploads/tmp/1488491505-93525-0003-2232/world.png", @original_filename="world.png", @content_type=nil>,
  #     @cache_storage=#<CarrierWave::Storage::File:0x007fcae48383d8 @uploader=#<Hyrax::UploadedFileUploader:0x007fcae3312288 ...>
  #   >,
  #   @versions={},
  #   @storage=#<CarrierWave::Storage::AWS:0x007fcadacbd408 @uploader=#<Hyrax::UploadedFileUploader:0x007fcae3312288 ...>, @connection=#<Aws::S3::Resource>>
  # >
  # connection: <Aws::S3::Resource>
  # path: "/Users/atz/repos/hyku/tmp/uploads/hyrax/uploaded_file/file/3/world.png"

  # With aws wired in, without stubbing, we would get failures telling us to:
  #   stub_request(:get, "http://169.254.169.254/latest/meta-data/iam/security-credentials/")
  #     .with(:headers => {'Host'=>'169.254.169.254:80', 'User-Agent'=>'excon/0.55.0'})
  #     .to_return(:status => 200, :body => 'AWS_DEFAULT_REGION', :headers => {})
  #   stub_request(:get, "http://169.254.169.254/latest/meta-data/placement/availability-zone/") ...
  #   stub_request(:get, "http://169.254.169.254/latest/meta-data/iam/security-credentials/AWS_DEFAULT_REGION") ...

  describe CarrierWave::Storage::AWS do
    let(:file) do
      # In Controller each file is like:
      ActionDispatch::Http::UploadedFile.new(
        tempfile: Tempfile.new,
        filename: 'world.png',
        content_type: 'image/png',
        headers: "Content-Disposition: form-data; name=\"files[]\"; filename=\"world.png\"\r\nContent-Type: image/png\r\nContent-Length: 4218\r\n"
      )
    end

    let(:config) do
      # reproduce initializer, since it is too late to trigger it by mocking Settings
      CarrierWave.configure do |config|
        # config.fog_provider = 'fog/aws'
        # config.fog_credentials = {
        #   provider: 'AWS',
        #   use_iam_profile: true
        # }
        config.storage = :aws
        config.aws_bucket = 'bucket_x'
        config.aws_acl = 'bucket-owner-full-control'
        config
      end
    end

    before do
      config # trigger our configuration
    end

    describe 'configuration' do
      it 'has CarrierWave-AWS values available' do
        expect(config.storage_engines).to match a_hash_including(aws: 'CarrierWave::Storage::AWS')
      end
      it 'has correct storage' do
        expect(config.storage).to eq(CarrierWave::Storage::AWS)
      end
      it 'has aws_bucket' do
        expect(config.aws_bucket).to eq('bucket_x')
      end
    end

    describe 'Using our substituted AWSFile object' do
      let(:connection) { Aws::S3::Resource.new('bucket_x') }
      let(:aws_file) do
        CarrierWave::Storage::AWSFile.new(double, connection, bigurl)
      end
      before do
        allow(aws_file).to receive(:store)
        expect(CarrierWave::Storage::AWSFile).to receive(:new).and_return aws_file
      end

      it_behaves_like 'Regular upload'

      it 'returns our AWSFile' do
        expect(upload.file.file).to eq aws_file
      end
    end
  end
end
