const formHeaders = {
  "Content-Type": "application/x-www-form-urlencoded"
};

async function fetchInfo() {
  const res = await fetch(`/info`);
  const json = await res.json();
  return json;
}

async function fetchImage(artist) {
  const res = await fetch(`/image?artist=${artist}`);
  const json = await res.json();
  return json;
}

async function postCommand(action) {
  const res = await fetch(`/command`, {
    method: "POST",
    headers: formHeaders,
    body: `action=${action}`
  });
  const json = await res.json();
  return json;
}
async function postVolume(change) {
  const res = await fetch(`/volume`, {
    method: "POST",
    headers: formHeaders,
    body: `vol=${change}`
  });
  const json = await res.json();
  return json;
}

export default { fetchImage, fetchInfo, postCommand, postVolume };
