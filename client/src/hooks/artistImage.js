import { useEffect, useState, useCallback } from "react";
import API from "../utils/api";

function useArtistImage({ artist }) {
  const [imageCache, setImageCache] = useState({});

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
      getArtistImage();
    }
  }, [artist, imageCache, getArtistImage]);

  return imageCache[artist];
}

export default useArtistImage;
