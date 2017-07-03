describe 'Entry' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Entry entity' do
    Entry.entity_description.name.should == 'Entry'
  end
end
