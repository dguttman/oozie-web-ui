# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_oozie_ui_session',
  :secret      => '7123b18081c3fbff831f5d2783610efe45929d0e8fb0ca94003027ca0f08409543381bb20c0a3aaaa407d471d50f4e30b50f5ef709f04fa5f8378e4996da7e79'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
