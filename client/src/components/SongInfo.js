import React from "react";

function SongInfo({ mpdInfo: { artist, title } }) {
  // if (!(artist || title)) return null;
  return (
    <div>
      <h1>{title}</h1>
      <h2>{artist}</h2>
    </div>
  );
}
export default SongInfo;
