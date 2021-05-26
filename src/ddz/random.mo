//import Random "mo:base/Random";
//import Option "mo:base/Option";
//import Iter "mo:base/Iter";
//import Array "mo:base/Array";
import Word32 "mo:base/Word32";
import Time "mo:base/Time"

module {

// 这个接口不能在query接口中使用
public class Random() {
  var state0: Word32 = Word32.fromInt(Time.now());
  var state1: Word32 = Word32.fromInt(Time.now());

  public func rand(): Nat {
    var s1 = state0;
    var s0 = state1;
    state0 := s0;
    s1 ^= s1 << Word32.fromNat(23);
    s1 ^= s1 >> Word32.fromNat(17);
    s1 ^= s0;
    s1 ^= s0 >> Word32.fromNat(26);
    state1 := s1;
    return Word32.toNat(state0) + Word32.toNat(state1);
  };
};

  //public func rand
  /*
  func getBytes(n : Nat) : async [Word8] {
    let m = (n + 31) / 32;
    var chunk = Iter.fromArray<Word8>([]);
    let beacons = Array.init(m, chunk);
    for (i in Iter.range(0, m - 1)) {
      beacons[i] := (await Random.blob()).bytes();
    };
    let source = Iter.fromArrayMut(beacons);
    Array.tabulate<Word8>(n, func _ {
      switch (chunk.next()) {
        case (?x) x;
        case (null) {
          chunk := Option.unwrap(source.next());
          Option.unwrap(chunk.next())
        }
      }
    })
  };
  */
};