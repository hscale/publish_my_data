  # Default PublishMyData routes:
  #   Note that there is no default home page route for publish_my_data. You need to define your own. e.g.
  
  get '/', to: redirect('/data'), as: :home # use the data catalogue
  
  #   or:
  # match '/' => 'home#home', as: 'home'

  mount PublishMyData::Engine, at: '/'
  
