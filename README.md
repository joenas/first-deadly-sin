# the First Deadly Sin[\*](http://www.imdb.com/title/tt0080738/)

This is a Sinatra web client for a remote or local MPD, with Faye for syncing between clients.
Layout and image fetching is a shameless rip-off of [So-nice](https://github.com/sunny/so-nice).

In Ubuntu, this integrates nicely with [Fogger](https://apps.ubuntu.com/cat/applications/fogger/).
On Mac OS X you can try [Fluid](http://fluidapp.com/).

Thanks to the awesome callbacks of [ruby-mpd](https://github.com/archSeer/ruby-mpd) this app now uses a MPD listener to push changes to all clients.
For a version that uses Redis and a stores the artists images locally, checkout branch [local_store](https://github.com/joenas/first-deadly-sin/tree/local_store).

# Spotify

You need to create a [Spotify application](https://developer.spotify.com/my-applications) to obtain a Client ID and Client Secret. Spotify is used to fetch artist images, since Last FM [removed their support](https://www.reddit.com/r/lastfm/comments/bjwcqh/api_announcement_lastfm_support_community/) for this.

# Usage

```bash
# Build the client
(cd client && yarn && yarn build)

# Server #
cd server

# Add your Spotify credentials
cp .env.example .env

# Install gems
bundle install

# Start server
foreman start

# or if you already have Faye running (on port 9292)
bundle exec thin start (-p port)
```

# Docker

To run the server in Docker, use the included `docker-compose.yml`.

You also need to set `FAYE_SERVER_URL=http://faye:9292/faye` in `.env`, because of the internal network.

```bash
# Choose whatever name you prefer, edit in docker-compose.yml
docker network create firstdeadlysin
docker-compose build
docker-compose up -d
```

# Development

Start the client

```
# Client
cd client
yarn
yarn start
```

Start servers, with Foreman

```bash
cd server
foreman start -f Procfile
```

or separately

```
# Server
cd server
bundle exec thin start -p 4000
rackup faye.ru -E production
```
