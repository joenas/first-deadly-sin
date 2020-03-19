// TODO: env or something
const HOST = "http://localhost:4000";

const formHeaders = {
  "Content-Type": "application/x-www-form-urlencoded"
};

async function fetchInfo() {
  const res = await fetch(`${HOST}/info`);
  const json = await res.json();
  return json;
}

async function fetchImage(artist) {
  const res = await fetch(`${HOST}/image?artist=${artist}`);
  const json = await res.json();
  return json;
}

async function postCommand(action) {
  const res = await fetch(`${HOST}/command`, {
    method: "POST",
    headers: formHeaders,
    body: `action=${action}`
  });
  const json = await res.json();
  return json;
}
async function postVolume(change) {
  const res = await fetch(`${HOST}/volume`, {
    method: "POST",
    headers: formHeaders,
    body: `vol=${change}`
  });
  const json = await res.json();
  return json;
}

export default { fetchImage, fetchInfo, postCommand, postVolume };
