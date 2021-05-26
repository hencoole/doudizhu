import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Poker "poker";
import Player "player";

module {

public type Card = Poker.Card;
public type TableId = Nat;
public type SeatId = Nat;

public type TableMsg {
  #NoneMsg: {
    seat: SeatId;
  };

  #JoinMsg: {
    seat: SeatId;
    player: PlayerState;
  };

  #LeaveMsg: {
    seat: SeatId;
  };

  #ReadyMsg: {
    seat: SeatId;
  };

  #StartMsg: {
    cur_seat: SeatId;
    cards: [Card];
  };

  #CallMsg: {
    cur_seat: SeatId;
    is_call: SeatId;
    cur_score: Nat;
  };

  #BankerMsg: {
    cur_seat: SeatId;
    banker_seat: SeatId;
    banker_score: Nat;
    cards: [Card];
  };

  #OutMsg: {
    cur_seat: SeatId;
    out_seat: SeatId;
    cards: [Card];
  };

  #PassMsg: {
    cur_seat: SeatId;
    pass_seat: SeatId;
  };

  #OverMsg: {
    scores: [Nat];
    spring: Bool;
    antispring: Bool;
    call_score: Nat;
    boom_count: Nat;
  };
};

}