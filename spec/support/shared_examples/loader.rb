RSpec.shared_examples "a loader" do
  it "implements the Loader contract (#load)" do
    expect(described_class.instance_methods).to include(:load)
  end

  it "returns an Enumerable from #load" do
    expect(subject.load).to be_a(Enumerable)
  end
end