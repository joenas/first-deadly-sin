# the First Deadly Sin[*](http://www.imdb.com/title/tt0080738/)
This is a Sinatra web client for a remote or local MPD, with Faye for syncing between clients.  
Layout and image fetching is a shameless rip-off of [So-nice](https://github.com/sunny/so-nice).  

In Ubuntu, this integrates nicely with [Fogger](https://apps.ubuntu.com/cat/applications/fogger/).
On Mac OS X you can try [Fluid](http://fluidapp.com/).

Thanks to the awesome callbacks of [ruby-mpd](https://github.com/archSeer/ruby-mpd) this app now uses a MPD listener to push changes to all clients.  
For a version that uses Redis and a stores the artists images locally, checkout branch [local_store](https://github.com/joenas/first-deadly-sin/tree/local_store).

# Usage
```bash
$ foreman start (-p port) # default is 3000
# or if you already have Faye running (on port 9292)
$ thin start (-p port)
```


