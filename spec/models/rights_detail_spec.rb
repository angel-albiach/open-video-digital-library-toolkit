require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RightsDetail do
  before(:each) do
    @valid_attributes = {
      :statement => "some rights statement",
      :license => "a way of labeling it",
      :property_type => PropertyType.find_by_name( "Rights Statement" )
    }

  end

  def create_rd
    rd = RightsDetail.new @valid_attributes
    rd.save
  end

  it "should create a new instance given valid attributes" do
    create_rd.should be_true
  end

  it "should require license" do
    @valid_attributes.delete :license
    create_rd.should be_false
  end

  it "should require statement" do
    @valid_attributes.delete :statement
    create_rd.should be_false
  end

  it "should require license be unique" do
    create_rd.should be_true
    create_rd.should be_false
  end

  it "should insert a property type if none given" do
    @valid_attributes.delete :property_type
    create_rd.should be_true
  end

  it "should disallow destroy if properties exit" do
    rd = RightsDetail.find_by_license "All Rights Reserved"
    rd.destroy.should be_false
  end

  it "should allow destroy if no properties exit" do
    rd = RightsDetail.find_by_license "All Rights Reserved"
    rd.destroy.should be_false
  end

end
