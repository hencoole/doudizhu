import Text "mo:base/Text";
import Prim "mo:prim";

module {

// Convert text to lower case
public func to_lowercase(name: Text) : Text {
  var str = "";
  for (c in Text.toIter(name)) {
    let ch = if ('A' <= c and c <= 'Z') { Prim.word32ToChar(Prim.charToWord32(c) +% 32) } else { c };
    str := str # Prim.charToText(ch);
  };
  str
};

// Text equality check ignoring cases.
public func eq_nocase(s: Text, t: Text) : Bool {
  let m = s.size();
  let n = t.size();
  m == n and to_lowercase(s) == to_lowercase(t)
};

}