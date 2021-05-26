import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Char "mo:base/Char";
import Utils "utils";


module {

public type Result<T,E> = Result.Result<T,E>;
public type PlayerId = Principal;
public type PlayerName = Text;
public type Score = Nat;

public type PlayerState = {
  id: PlayerId;
  name: PlayerName;
  var score: Score;
};

public type PlayerView = {
  name: PlayerName;
  score: Score;
};

public type RegistrationError = {
  #InvalidName;
  #NameAlreadyExists;
};

// Check if player name is valid, which is defined as:
// 1. Between 3 and 10 characters long
// 2. Alphanumerical. Special characters like  '_' and '-' are also allowed.
public func valid_name(name: Text): Bool {
  let str : [Char] = Iter.toArray(Text.toIter(name));
  if (str.size() < 3 or str.size() > 10) {
    return false;
  };
  for (i in Iter.range(0, str.size() - 1)) {
    let c = str[i];
    if (not (Char.isDigit(c) or Char.isAlphabetic(c) or (c == '_') or (c == '-'))) {
      return false;
    }
  };
  true
};

public class Manager(accounts : [(PlayerId, PlayerState)]) {
  //let id_map: HashMap.HashMap<PlayerId, PlayerState> = HashMap.HashMap<PlayerId, PlayerState>(10, func (x, y) { x == y }, Principal.hash);
  //let name_map: HashMap.HashMap<PlayerName, PlayerId> = HashMap.HashMap<PlayerName, PlayerId>(10, func (x, y) { x == y }, Text.hash);
  
  let id_map: HashMap.HashMap<PlayerId, PlayerState> = HashMap.fromIter<PlayerId, PlayerState>(
    accounts.vals(), accounts.size(), func (x, y) { x == y }, Principal.hash
  );
  let name_map: HashMap.HashMap<PlayerName, PlayerId> = HashMap.fromIter<PlayerName, PlayerId>(
    Iter.map<(PlayerId, PlayerState), (PlayerName, PlayerId)>(
      accounts.vals(), func ((id, state)) { (Utils.to_lowercase(state.name), id) }
    ), accounts.size(), func (x, y) { x == y }, Text.hash
  );
  
  public func get_player_by_id(uid: PlayerId) : ?PlayerState {
    id_map.get(uid)
  };

  func get_id_by_name(uname: PlayerName) : ?PlayerId {
    name_map.get(Utils.to_lowercase(uname))
  };

  func get_player_by_name(uname: PlayerName) : ?PlayerState {
    switch (get_id_by_name(uname)) {
      case null { null };
      case (?id) { get_player_by_id(id) };
    }
  };

  func insert_new_player(uid: PlayerId, uname: PlayerName) : PlayerState {
    let player = {id = uid; name = uname; var score = 0; };
    id_map.put(uid, player);
    name_map.put(Utils.to_lowercase(uname), uid);
    player
  };

  func player_state_to_view(player: PlayerState): PlayerView {
    { name = player.name; score = player.score; }
  };

  public func get_id_map(): HashMap.HashMap<PlayerId, PlayerState>{
    id_map
  };

  public func register(uid: PlayerId, uname: Text): Result<PlayerView, RegistrationError> {
    //let player_id = msg.caller;
    switch (get_player_by_id(uid), valid_name(uname)) {
      case (?player, _) {
        //Utils.update_recent_players(recent_players, player.name);
        #ok(player_state_to_view(player))
      };
      case (_, false) (#err(#InvalidName));
      case (null, true) {
        switch (get_id_by_name(uname)) {
          case null {
              let player = insert_new_player(uid, uname);
              //Utils.update_recent_players(recent_players, name);
              #ok(player_state_to_view(player))
          };
          case (?_) (#err(#NameAlreadyExists));
        }
      }
    }
  };

  public func update_score(player_id: PlayerId, score: Score){

  }
};


}