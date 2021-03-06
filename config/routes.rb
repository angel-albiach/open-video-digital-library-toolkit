ActionController::Routing::Routes.draw do |map|

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'

  map.resources :users

  map.resources :saved_queries
  map.resources :favorites
  map.resources :downloads

  map.activate '/activate/:activation_code',
               :controller => 'users',
               :action => 'activate',
               :activation_code => nil

  map.forgot_password '/forgot_password',
                      :conditions => { :method => :get },
                      :controller => 'users',
                      :action => 'forgot_password'
    
  map.forgot_password '/forgot_password',
                      :conditions => { :method => :post },
                      :controller => 'users',
                      :action => 'forgot_password'
    
  map.reset_password '/reset_password/:id',
                      :conditions => { :method => :get },
                      :controller => 'users',
                      :action => 'reset_password'
    
  map.reset_password '/reset_password/:id',
                      :conditions => { :method => :post },
                      :controller => 'users',
                      :action => 'change_password'
    
  map.resources :videos, :collection => { :recent => :get,
                                          :popular => :get,
                                          :cancel => :get,
                                          :clear => :get,
                                          :images => :get,
                                          :convert => :post
                         },
                         :member => { :download => :get,
                                      :reset => :get
                         } do |videos|
    videos.resources :assets
  end

  map.videos_home "/videos/home/:style", :controller => "videos",
                                         :action => "home"

  map.resources :assets, :collection => { :uncataloged => :any }

  map.resource :library, :controller => :library,
                         :member => { :users => :get,
                                      :remove_users => :post,
                                      :add_role => :post,
                                      :remove_role => :post,
                                    }


  map.resource :import, :controller => :import

  map.resources :import_maps,
                :member => { :yml => :get,
                             :save_yml => :post,
                             :template => :post }

  map.resource :my, :controller => :my,
                    :member => { :home => :get,
                                 :favorites => :get,
                                 :my_account => :get,
                                 :saved_searches => :get,
                                 :downloaded_videos => :get,
                                 :playlists => :get,
                                 :password => :put,
                               }

  map.connect "/collections/featured/order", :controller => "collections",
                                              :action => "featured_order",
                                              :conditions => { :method => :post }

  map.connect "/collections/priority/order", :controller => "collections",
                                             :action => "priority_order",
                                             :conditions => { :method => :post }

  map.connect "/videos/featured/order", :controller => "videos",
                                        :action => "featured_order",
                                        :conditions => { :method => :post }

  map.connect "/library/property_type/order", :controller => "library",
                                              :action => "property_type_order",
                                              :conditions => { :method => :post }

  map.connect "/library/descriptor_value/order", :controller => "library",
                                                 :action => "descriptor_value_order",
                                                 :conditions => { :method => :post }

  map.resources :collections,
                :collection => { :collections => :get,
                                 :playlists => :get,
                               } do |collections|

    collections.resources :bookmarks

  end

  map.resources :bookmarks, :collection => { :order => :put },
                            :member => { :annotation => :put }

  map.resources :sessions

  map.connect 'home/:action', :controller => "home"
  
  map.connect "tagging/:action", :controller => "tagging"

  map.root :controller => 'home'
  
end
