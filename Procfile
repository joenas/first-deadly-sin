app: rackup first_sin.ru -p $PORT
faye: rackup faye.ru -E production
sidekiq: sidekiq -r ./first_sin.rb
sidekiq_web: rackup sidekiq.ru -p 5000
