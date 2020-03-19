import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faBackward,
  faPlay,
  faPause,
  faStop,
  faForward,
  faVolumeDown,
  faVolumeUp
  // faRedo
} from "@fortawesome/free-solid-svg-icons";
import API from "../utils/api";

function Icon({ icon, active }) {
  const className = active ? "active" : "";
  return (
    <FontAwesomeIcon className={className} icon={icon} size="sm" fixedWidth />
  );
}

function Control({ children, onClick, activeState, currentState }) {
  const active = !!activeState && activeState === currentState;
  return (
    <button onClick={onClick}>
      {React.cloneElement(children, { active })}
    </button>
  );
}

function Controls({ currentState }) {
  return (
    <div className="btn-group" id="mpd-buttons">
      <Control
        onClick={() => {
          API.postCommand("previous");
        }}
      >
        <Icon icon={faBackward} />
      </Control>

      <Control
        onClick={() => {
          API.postCommand("play");
        }}
        activeState="play"
        currentState={currentState}
      >
        <Icon icon={faPlay} />
      </Control>

      <Control
        onClick={() => {
          API.postCommand("pause");
        }}
        activeState="pause"
        currentState={currentState}
      >
        <Icon icon={faPause} />
      </Control>

      <Control
        onClick={() => {
          API.postCommand("stop");
        }}
        activeState="stop"
        currentState={currentState}
      >
        <Icon icon={faStop} />
      </Control>

      <Control
        onClick={() => {
          API.postCommand("next");
        }}
      >
        <Icon icon={faForward} />
      </Control>

      <Control
        onClick={() => {
          API.postVolume("voldown");
        }}
      >
        <Icon icon={faVolumeDown} />
      </Control>

      <Control
        onClick={() => {
          API.postVolume("volup");
        }}
      >
        <Icon icon={faVolumeUp} />
      </Control>

      {/* <Control
        onClick={() => {
          API.postCommand();
        }}
      >
        <Icon icon={faRedo} />
      </Control> */}
    </div>
  );
}

export default Controls;
