require 'digest/sha1'

class User < ActiveRecord::Base
  
  has_many :permissions, :dependent => :destroy  
  has_many :roles, :through => :permissions

  has_many :searches, :order => "created_at desc"
  has_many :collections, :order => "collections.priority desc, collections.updated_at desc"

  has_one :favorites, :class_name => "Collection", :dependent => :destroy
  has_one :downloads, :class_name => "Collection", :dependent => :destroy

  [ :favorites, :downloads ].each do |collection_name|
    define_method collection_name do
      collection = nil
      if (self.send "#{collection_name}_id".to_sym).nil?
        collection = Collection.create! :user_id => id,
                                         :title => "#{login} #{collection_name}"
        self.send "#{collection_name}_id=".to_sym, collection.id
        # self.send "#{collection_name}=".to_sym, collection
        save!
      else
        collection = Collection.find(self.send( "#{collection_name}_id"))
      end
      collection
    end
  end

  def special_collection? c
    c.id == favorites_id or c.id == downloads_id
  end

  # needs to move ...
  def playlists params = nil
    options = { :conditions => 
                        [ "user_id = ? and id not in (#{favorites.id}, #{downloads.id})", id ] }
    method = :find
    if params
      method = :paginate
      options.merge!( { :page => params[:page], :per_page => 5 } )
    end
    Collection.send method, :all, options
  end


  # has_role? simply needs to return true or false whether a user has
  # a role or not.  It may be a good idea to have "admin" roles return




  # true always

  def has_role?(role_in_question)
    @_list ||= self.roles.collect(&:name)
    return true if @_list.include?("admin")
    Array(role_in_question).detect { |role| @_list.include? role.to_s }
  end

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def forgot_password
    @forgotten_password = true
    make_password_reset_code
  end  

  def recently_forgot_password?
    @forgotten_password
  end
    
  def recently_reset_password?
    @reset_password
  end

  def reset_password
    if valid?
      self.password_reset_code = nil
      save
    end
  end

  protected
    
  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

end
