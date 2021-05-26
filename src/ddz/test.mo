import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Word8 "mo:base/Word8";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Poker "poker";
import Player "player";


actor {
  public type Card = Poker.Card;
  public type CardType = Poker.CardType;
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

  var rand_poker: Poker.RandomPoker = Poker.RandomPoker();
  var cards_array:[[Card]] = [];

  public func poker_test(): async Text {
    let cards:[Card] = rand_poker.get();
    cards_array := Poker.dispatch(cards);
    Poker.toText(cards)
    //Array.tabulate<Nat>(cards.size(), func(i:Nat) : Nat {Nat8.toNat(cards[i])})
  };

  public func poker_get(n: Nat) : async Text{
    Poker.toText(cards_array[n])
  };

  public func poker_get_card_type_test() : async Text {
    // #SingleLine
    let c1: [Card] = [0x07,0x06,0x05,0x04,0x03];
    let t1 = Poker.get_card_type(c1);
    Debug.print(debug_show(("t1:", t1)));

    // #TripleTakeDouble
    let c2: [Card] = [0x03,0x13,0x23,0x06,0x16];
    //let c22 = Poker.sort(c2);
    //Debug.print(debug_show(("c22:", Poker.toText(c22))));
    let t2 = Poker.get_card_type(Poker.sort(c2));
    Debug.print(debug_show(("t2:", t2)));

    // #DoubleLine
    let c3: [Card] = [0x03,0x13,0x24,0x04,0x15,0x25];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let t3 = Poker.get_card_type(Poker.sort(c3));
    Debug.print(debug_show(("t3:", t3)));

    // #TripleTakeSingle
    let c4: [Card] = [0x0A,0x1A,0x2A,0x04];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let t4 = Poker.get_card_type(Poker.sort(c4));
    Debug.print(debug_show(("t4:", t4)));

    // #Bomb
    let c5: [Card] = [0x02,0x12,0x22,0x32];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let t5 = Poker.get_card_type(Poker.sort(c5));
    Debug.print(debug_show(("t5:", t5)));

    // #Missile
    let c6: [Card] = [0x4E,0x4F];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let t6 = Poker.get_card_type(Poker.sort(c6));
    Debug.print(debug_show(("t6:", t6)));

    // #Single
    let c7: [Card] = [0x2B];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let t7 = Poker.get_card_type(Poker.sort(c7));
    Debug.print(debug_show(("t7:", t7)));

    // #Double
    let c8: [Card] = [0x21, 0x01];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let t8 = Poker.get_card_type(Poker.sort(c8));
    Debug.print(debug_show(("t8:", t8)));

    // #Triple
    let c9: [Card] = [0x0D, 0x1D, 0x2D];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let t9 = Poker.get_card_type(Poker.sort(c9));
    Debug.print(debug_show(("t9:", t9)));

    // #FourTakeSingle
    let ca: [Card] = [0x0D, 0x1D, 0x2D, 0x3D, 0x21, 0x2B];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let ta = Poker.get_card_type(Poker.sort(ca));
    Debug.print(debug_show(("ta:", ta)));

    // #FourTakeDouble
    let cb: [Card] = [0x09, 0x19, 0x29, 0x39, 0x21, 0x01, 0x23, 0x03];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let tb = Poker.get_card_type(Poker.sort(cb));
    Debug.print(debug_show(("tb:", tb)));

    
    // #TripleLine
    let cc: [Card] = [0x03, 0x13, 0x23, 0x34, 0x24, 0x04];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let tc = Poker.get_card_type(Poker.sort(cc));
    Debug.print(debug_show(("tc:", tc)));

    // #Error
    let cd: [Card] = [0x03, 0x34, 0x25];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let td = Poker.get_card_type(Poker.sort(cd));
    Debug.print(debug_show(("td:", td)));

    // #Error
    let ce: [Card] = [0x01, 0x32, 0x23];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let te = Poker.get_card_type(Poker.sort(ce));
    Debug.print(debug_show(("te:", te)));

    // #Error
    let cf: [Card] = [0x01, 0x32];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let tf = Poker.get_card_type(Poker.sort(cf));
    Debug.print(debug_show(("tf:", tf)));

    // #Error
    let cg: [Card] = [0x0b, 0x3c, 0x3d, 0x01, 0x32];
    //let c33 = Poker.sort(c3);
    //Debug.print(debug_show(("c33:", Poker.toText(c33))));
    let tg = Poker.get_card_type(Poker.sort(cg));
    Debug.print(debug_show(("tg:", tg)));

    "greet !!!"
    //Poker.toText(Array.freeze(cards_array[n]))
  };
  
  public func poker_get_card_type(cards: [Card]) : async CardType {
    Poker.get_card_type(Poker.sort(cards))
  };

  public func poker_compare(a: [Card], b: [Card]) : async Bool {
    Poker.compare(a, b)
  };

  
  public func poker_remove(n: Nat) : async Text {
    let var_arr = Array.thaw<[Card]>(cards_array);

    let before = Poker.toText(var_arr[n]);
    var res: Text = "Before:" # before;
    Debug.print("Before:" # before);
    let tc = [var_arr[n][2],var_arr[n][3],var_arr[n][5],var_arr[n][7]];
    var_arr[n] := Poker.remove(var_arr[n], tc);
    let after = Poker.toText(var_arr[n]);
    res :=  res # "--- after:" # after;
    cards_array := Array.freeze<[Card]>(var_arr);
    Debug.print("After:" # after);
    res
  };

  public func two_array(): async Text{
    var arr: [[var Nat]] = [];
    for (i in Iter.range(0,1)){
      arr := Array.append(arr, [Array.init<Nat>(2, 0)]);
    };

    arr[0][0] := 1;
    arr[1][0] := 2;

    Debug.print("--0,0:" # Nat.toText(arr[0][0]));
    Debug.print("--1,0:" # Nat.toText(arr[1][0]));
    
    arr[0][0] := 3;
    arr[1][0] := 4;
/*
    var arr2: [[Nat]] = [];
    for (i in Iter.range(0,1)){
      arr2 := Array.append(arr2, [Array.freeze(arr[i])]);
    };
*/
    let arr2 = Array.tabulate<[Nat]>(arr.size(), func (i) {Array.freeze(arr[i])});

    Debug.print("++0,0:" # Nat.toText(arr2[0][0]));
    Debug.print("++1,0:" # Nat.toText(arr2[1][0]));
    "greet !!!"
  };

  public func word_test(n: Nat): async Text{
    let m = Word8.fromNat(n);
    Word8.toText(m)
  };

  let map: HashMap.HashMap<Nat, Nat> = HashMap.HashMap<Nat, Nat>(4, func (x, y) { x == y }, Hash.hash);
  public func hashmap_put(k:Nat, v:Nat): async Nat {
    map.put(k, v);
    v
  };
  public func hashmap_get(k:Nat): async Nat {
    switch(map.get(k)) {
      case null {0};
      case (?value) {value};
    }
  };

  //type NatArray = [Nat];
  let tarray: [var [var Nat]] = Array.init<[var Nat]>(4, Array.init<Nat>(20, 0));
  public func array_put(x:Nat, y:Nat, v:Nat): async Nat {
    tarray[x][y] := v;
    v
  };
  public func array_get(x:Nat, y:Nat): async Nat {
    tarray[x][y]
  };
  public func array_get2(x:Nat): async [Nat] {
    Array.freeze(tarray[x])
  };

  let aa: [Nat] = [1,2,3,4];
  let bb: [Nat] = [1,2];

  public func array_remove(): async [Nat] {
    Array.filter<Nat>(aa, func (x) { Option.isNull(Array.find<Nat>(bb, func (y){x == y})) });
  };
};
