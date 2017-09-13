RSpec.describe SingleAttributeRenderer do
  let(:field) { :name }
  let(:renderer) { described_class.new(field, ['']) }

  describe "#render" do
    subject { renderer.render }

    context 'single-valued field with no content' do
      it { expect(subject).to eq('') }
    end

  end
end