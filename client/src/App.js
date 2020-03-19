import React from "react";
import Controls from "./components/Controls";
import SongInfo from "./components/SongInfo";
import useMpdInfo from "./hooks/mpdInfo";
import useArtistImage from "./hooks/artistImage";

function App() {
  const { mpdInfo } = useMpdInfo();
  const artistImage = useArtistImage(mpdInfo);
  const backgroundImage = artistImage ? `url(${artistImage})` : "none";

  return (
    <div className="App" style={{ backgroundImage }}>
      <div className="wrapper">
        <SongInfo mpdInfo={mpdInfo} />
        <Controls currentState={mpdInfo.state} />
      </div>
    </div>
  );
}

export default App;
