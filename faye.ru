# call with rackup faye.ru -s thin -E production or s**t will break
# now via foreman!

require 'faye'

Faye::WebSocket.load_adapter('thin')
run Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)