import { useEffect, useState, useCallback } from "react";
import API from "../utils/api";

function useArtistImage({ artist }) {
  const [imageCache, setImageCache] = useState({});
  const [lastArtist, setLastArtist] = useState(null)

  const getArtistImage = useCallback(async () => {
    try {
      const data = await API.fetchImage(artist);
      setImageCache({ ...imageCache, [artist]: data.url });
    } catch (e) {
      console.error(e.message);
    }
  }, [imageCache, setImageCache, artist]);

  useEffect(() => {
    if (artist && !imageCache[artist]) {
      setLastArtist(artist)
      getArtistImage();
    }
  }, [artist, imageCache, getArtistImage]);

  // To prevent image flashing when changing track (MPD sets state to 'stop' for a split second)
  return imageCache[artist || lastArtist];
}

export default useArtistImage;
