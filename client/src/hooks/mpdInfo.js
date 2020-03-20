import { useEffect, useState, useCallback } from "react";
import { fayeSubscription } from "../utils/fayeSubscription";
import API from "../utils/api";

function useMpdInfo() {
  const [mpdInfo, setMpdInfo] = useState({});
  const [fayeConnected, setFayeConnected] = useState(false);

  const getMdpInfo = useCallback(async () => {
    try {
      const data = await API.fetchInfo();
      setMpdInfo(data);
    } catch (e) {
      console.error(e);
    }
  }, [setMpdInfo]);

  useEffect(() => {
    const updateMpdInfo = msg => {
      console.log({ faye: msg });
      setMpdInfo(msg["info"]);
    };
    return fayeSubscription("/first-sin/mpd", updateMpdInfo, setFayeConnected);
  }, []);

  useEffect(() => {
    getMdpInfo();
  }, [getMdpInfo]);

  return { mpdInfo, fayeConnected };
}

export default useMpdInfo;
