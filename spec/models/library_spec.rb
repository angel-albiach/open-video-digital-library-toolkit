require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Library do
  before(:each) do

    ( Library.find :all ).each { |library| library.destroy }

    @valid_attributes = {
      :title => "Library title",
      :subtitle => "about a library",
      :my => "My Library",
      :collections_login => "collections"
    }

  end

  it "should create a new instance given valid attributes" do
    Library.create!(@valid_attributes)
  end

  it "should reject a new instance without a my string" do
    @valid_attributes.delete :my
    ( Library.create @valid_attributes ).save.should be_false
  end

  it "should reject a new instance without a title" do
    @valid_attributes.delete :title
    ( Library.create @valid_attributes ).save.should be_false
  end

  it "should allow a new instance without a subtitle" do
    @valid_attributes.delete :subtitle
    ( Library.create @valid_attributes ).save.should be_true
  end

  describe ".title" do
    it "should return the title of some library record" do
      s = "a title"
      my = "my title"
      Library.create! :title => s,
                       :my => my,
                       :collections_login => "collections"

      Library.title.should == s
    end
  end

  describe ".subtitle" do
    it "should return the subtitle of some library record" do
      t = "a title"
      s = "a subtitle"
      my = "my title"
      Library.create! :title => t,
                       :subtitle => s,
                       :my => my,
                       :collections_login => "collections"
      Library.subtitle.should == s
    end
  end

  describe ".logo_url" do
    it "should return the logo_url of some library record" do
      t = "a title"
      s = "a logo_url"
      my = "my title"
      Library.create! :title => t,
                       :logo_url => s,
                       :my => my,
                       :collections_login => "collections"
      Library.logo_url.should == s
    end
  end

  describe "#collections_login" do

    before(:each) do
      t = "a title"
      s = "a logo_url"
      my = "my title"
      @l = Library.create! :title => t,
                            :logo_url => s,
                            :my => my,
                            :collections_login => "collections"
    end

    it "should return the current value" do
      Library.find(:first).collections_login.should == "collections"
    end

    it "should allow update to a valid user the current value" do
      @l.collections_login =
        User.find( :first,
                    :conditions => [ "login <> ?",
                                     @l.collections_login ] ).login
      @l.save.should_not be_nil
      Library.find(:first).collections_login.should_not == "collections"
    end


    it "should not allow update to an invalid user" do
      @l.collections_login = "xyzzy"
      @l.save.should be_false
      @l.errors_on(:collections_user).should_not be_nil
      Library.find(:first).collections_login.should == "collections"
    end


  end

end

