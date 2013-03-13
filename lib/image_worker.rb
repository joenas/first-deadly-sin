require 'sidekiq'
class ImageWorker
  include Sidekiq::Worker

  def perform(artist, base_path, urls)
    image_fetcher = ImageFetcher.new(artist, base_path)
    urls.each do |url|
      image_fetcher.fetch_and_persist(url)
    end
  end
end