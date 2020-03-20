import React from "react";

function SongInfo({ mpdInfo: { artist, album, title } }) {
  if (!(artist || title)) return null;
  return (
    <div>
      <h1>{title}</h1>
      <h2>{artist}</h2>
      <h3>{album}</h3>
    </div>
  );
}
export default SongInfo;
