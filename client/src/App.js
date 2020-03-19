import React from "react";

import "./App.css";
import Controls from "./components/Controls";
import useMpdInfo from "./hooks/mpdInfo";
import useArtistImage from "./hooks/artistImage";

function SongInfo({ mpdInfo: { artist, album, title } }) {
  if (!(artist || title)) return null;
  return (
    <div id="mpd-info" style={{ textAlign: "left" }}>
      <h1>{title}</h1>
      <h2>{artist}</h2>
      <h3>{album}</h3>
    </div>
  );
}

function App() {
  const { mpdInfo } = useMpdInfo();
  const artistImage = useArtistImage(mpdInfo);
  const backgroundImage = artistImage ? `url(${artistImage})` : "none";

  return (
    <div className="App" style={{ backgroundImage }}>
      <SongInfo mpdInfo={mpdInfo} />
      <Controls currentState={mpdInfo.state} />
    </div>
  );
}

export default App;
