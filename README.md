# the First Deadly Sin
This is a Sinatra web client for a remote or local MPD, with Faye for syncing between clients.

Layout and image fetching is a shameless rip-off of [So-nice](https://github.com/sunny/so-nice).

For a version that uses Redis and a stores the artists images locally, checkout branch local_store

# Usage
```
$ foreman start -p port
# or if you already have a Faye server running
$ rackup first_sin.rb -p port
```


