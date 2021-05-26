import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module {

public type PlayerId = Principal;
public type PlayerName = Text;
public type Score = Nat;

public type PlayerState = {
  name: PlayerName;
  var score: Score;
};

public type PlayerView = {
  name: PlayerName;
  score: Score;
};

public type Players = {
  id_map: HashMap.HashMap<PlayerId, PlayerState>;
  name_map: HashMap.HashMap<PlayerName, PlayerId>;
};



}