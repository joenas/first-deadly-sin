import Faye from "faye";

function fayeSubscription(channel, subscriptionCallback, statusCallback) {
  const client = new Faye.Client(
    "http://" + window.location.hostname + ":9292/faye"
  );
  const subscription = client.subscribe(
    channel,
    subscriptionCallback,
    statusCallback
  );
  client.bind("transport:down", () => {
    statusCallback(false);
  });
  client.bind("transport:up", () => {
    statusCallback(true);
  });

  return () => {
    subscription.cancel();
  };
}

export { fayeSubscription };
