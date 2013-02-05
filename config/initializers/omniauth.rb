Rails.application.config.middleware.user OmniAuth::Builder do
  provider :twitter, ENV['consumer_key'], ENV['consumer_secret']
end