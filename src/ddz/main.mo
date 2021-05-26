import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Poker "poker";
import Player "player";
import Game "game";
import Massage "message";

actor {
  public type GameId = Game.TableId;
  public type Result<T,E> = Result.Result<T,E>;

  stable var accounts : [(Player.PlayerId, Player.PlayerState)] = [];

  // Before upgrade, we must dump all player data to stable accounts.
  system func preupgrade() {
    accounts := Iter.toArray(player_manager.get_id_map().entries());
  };
  let player_manager: Player.Manager = Player.Manager(accounts);
  
  public shared(msg) func register(name: Text): async Result<Player.PlayerView, Player.RegistrationError> {
    player_manager.register(msg.caller, name)
  };

  let game_room: Game.Room = Game.Room();
  public shared (msg) func join(): async Result<Game.SeatId, Game.GameError> {
    let player_id = msg.caller;
    Debug.print(debug_show(("player:", player_id)));
    switch (player_manager.get_player_by_id(player_id)) {
      case null (#err(#PlayerNotFound));
      case (?player) {
        return game_room.join(player_id);
      };
    };
  };

  public shared (msg) func leave(): async Result<Game.SeatId, Game.GameError> {
    let player_id = msg.caller;
    Debug.print(debug_show(("player:", player_id)));
    switch (player_manager.get_player_by_id(player_id)) {
      case null (#err(#PlayerNotFound));
      case (?player) {
        return game_room.leave(player_id);
      };
    };
  };

  public shared (msg) func ready(): async Result<Game.SeatId, Game.GameError> {
    let player_id = msg.caller;
    Debug.print(debug_show(("player:", player_id)));
    switch (player_manager.get_player_by_id(player_id)) {
      case null (#err(#PlayerNotFound));
      case (?player) {
        return game_room.ready(player_id);
      };
    };
  };
  
  public shared (msg) func keepalive(): async Result<Massage.Msg, Game.GameError> {
    let player_id = msg.caller;
    Debug.print(debug_show(("player:", player_id)));
    switch (player_manager.get_player_by_id(player_id)) {
      case null (#err(#PlayerNotFound));
      case (?player) {
        return game_room.get_msg(player_id);
      };
    };
  };

  public shared (msg) func call(flag: Bool): async Result<Game.SeatId, Game.GameError> {
    let player_id = msg.caller;
    Debug.print(debug_show(("player:", player_id)));
    switch (player_manager.get_player_by_id(player_id)) {
      case null (#err(#PlayerNotFound));
      case (?player) {
        return game_room.call(player_id, flag);
      };
    };
  };
  
  public shared (msg) func out(cards: [Card]): async Result<Game.SeatId, Game.GameError> {
    let player_id = msg.caller;
    Debug.print(debug_show(("player:", player_id)));
    switch (player_manager.get_player_by_id(player_id)) {
      case null (#err(#PlayerNotFound));
      case (?player) {
        return game_room.out(player_id, cards);
      };
    };
  };
  
  public shared (msg) func pass(): async Result<Game.SeatId, Game.GameError> {
    let player_id = msg.caller;
    Debug.print(debug_show(("player:", player_id)));
    switch (player_manager.get_player_by_id(player_id)) {
      case null (#err(#PlayerNotFound));
      case (?player) {
        return game_room.out(player_id, cards);
      };
    };
  };
};
