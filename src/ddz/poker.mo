import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Random "random";

module {

public type Card = Nat8;
public type CardType = {
  #ErrorType;
  #Single;
  #Double;
  #Triple;
  #SingleLine;
  #DoubleLine;
  #TripleLine;
  #TripleTakeSingle;
  #TripleTakeDouble;
  #FourTakeSingle;
  #FourTakeDouble;
  #Bomb;
  #Rocket;
};

type AnalyseResult = {
  count: [Nat];
  cards: [[Card]];
};

let data: [Card] = [
  0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,	//方块 A - K
  0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,	//梅花 A - K
  0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,	//红桃 A - K
  0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,	//黑桃 A - K
  0x4E,0x4F
];

public class RandomPoker() {
  let random: Random.Random = Random.Random();
  public func get() : [Card]{
    let num = data.size();
    let cards: [var Card] = Array.tabulateVar<Card>(num, func(i:Nat) : Card {data[i]});
    for (i in Iter.range(0, num-1)){
      let j: Nat = random.rand()%num;
      let t = cards[i];
      cards[i] := cards[j];
      cards[j] := t;
    };
    Array.freeze<Card>(cards)
  };
};

public func get_color (card: Card) : Nat {
  //var c: Nat8 = Nat8.fromNat(card);
  Nat8.toNat((card & 0xF0) >> 4)
};

public func get_value (card: Card) : Nat {
  //var c: Nat8 = Nat8.fromNat(card);
  Nat8.toNat(card & 0x0F)
};

public func hex_text(card: Card): Text{
  let c = get_color(card);
  let v = get_value(card);
  let hex_chars: [Char] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
  Text.fromChar(hex_chars[c])#Text.fromChar(hex_chars[v])
};

public func toText(all: [Card]): Text{
  var res: Text = hex_text(all[0]);
  for (i in Iter.range(1, all.size()-1)) {
    res := res#","#hex_text(all[i])  
  };
  res
};

public func get_card_value(card:Card): Nat {
	//扑克属性
	let color = get_color(card);
	var value = get_value(card);
	//转换数值
	if (color == 4) {
    value += 2;
  };
  if(value <= 2) {
    value += 13;
  };
  value
};

// 将牌分成三组 17张 和 一组3张，
// 索引0，1，2为分发给玩家的牌 
// 索引3为3张的底牌
public func dispatch(cards: [Card]): [[Card]]{
  var div_arr: [[var Card]] = [];
  for (i in Iter.range(0, 2)){
    div_arr := Array.append(div_arr, [Array.init<Card>(17, 0)]);
  };

  for (i in Iter.range(3, cards.size()-1)) {
    let x = i%3;
    let y = i/3 - 1;
    div_arr[x][y] := cards[i];
  };

  div_arr := Array.append(div_arr, [Array.init<Card>(3, 0)]);
  
  for (i in Iter.range(0, 2)) {
    div_arr[3][i] := cards[i];
  };
  
  Array.tabulate<[Card]>(div_arr.size(), func (i) {Array.freeze(div_arr[i])})
};

public func sort(cards: [Card]): [Card]{
  let num = cards.size();
  let result = Array.thaw<Card>(cards);
  let sarr = Array.tabulateVar<Nat>(num, func (i) {return get_card_value(cards[i]);});
  var is_sorted: Bool = false;
  var last = num - 1;
  loop {
    is_sorted := false;
    for (i in Iter.range(0, last-1)) {
      if ((sarr[i] < sarr[i + 1]) or 
          ((sarr[i] == sarr[i + 1]) and (result[i] < result[i + 1]))) {
        is_sorted := true;

        let ta = result[i];
        result[i] := result[i + 1];
        result[i + 1] := ta;

        let tb = sarr[i];
        sarr[i] := sarr[i + 1];
        sarr[i + 1] := tb;
      } else {
        last -= 1;
      }
    };
  } while (is_sorted);
  return Array.freeze<Card>(result);
};

// 从一组牌中删除一组牌
public func remove(all: [Card], cards: [Card]): [Card] {
  Array.filter<Card>(all, func (x) { Option.isNull(Array.find<Card>(cards, func (y){x == y})) });
};

// 分析牌的组成
public func analyse(cards: [Card]): AnalyseResult{
  var _count = Array.init<Nat>(4, 0);
  var _cards: [[var Card]]  = [];
  
  //Array.init<[var Card]>(4, Array.init<Card>(20, 0))
  for (i in Iter.range(0, 3)){
    //cards[i] := Array.init<Card>(20, 0);
    _cards := Array.append(_cards, [Array.init<Card>(20, 0)]);
  };

  let num = cards.size();
  var i = 0;
  while (i < num) {
    var same = 1;
    let value = get_card_value(cards[i]);
    label outer for (j in Iter.range(i + 1, num-1)) {
      if (get_card_value(cards[j]) != value) {
        break outer;
      }else{
        same += 1;
      }
    };
    let idx = _count[same - 1];
    _count[same - 1]  += 1;
    for (j in Iter.range(0, same-1)) {
      _cards[same-1][idx*same+j] := cards[i+j];
    };
    //设置索引
		i+=same;
  };

  //Debug.print(debug_show(("count:", _count)));
  //Debug.print(debug_show(("cards:", _cards)));
  {
    count = Array.freeze(_count); 
    cards = Array.tabulate<[Card]>(_cards.size(), func (i) {Array.freeze(_cards[i])});
  }
};

// 获取一组牌的类型
public func get_card_type(cards:[Card]): CardType{
  let num = cards.size();
  
  switch(num) {
    //空牌
    case 0 { return #ErrorType;};
    //单牌
    case 1 { return #Single; };
    case 2 {
      //火箭
      if ((cards[0] == Nat8.fromNat(0x4F)) and (cards[1] == Nat8.fromNat(0x4E))) { return #Rocket; };
      
      //对牌
			if (get_card_value(cards[0])==get_card_value(cards[1])) {return #Double; };
      
      //错误牌
      return #ErrorType;
    };
    case _ {}; 
  };
  
  //分析扑克
  let result: AnalyseResult = analyse(cards);
  
  //四牌判断
	if (result.count[3] > 0){
		//牌型判断
		if ((result.count[3]==1) and (num==4)) {return #Bomb;};
		if ((result.count[3]==1) and (num==6)) {return #FourTakeSingle;};
		if ((result.count[3]==1) and (num==8) and (result.count[1]==2)) {return #FourTakeDouble;};

    //错误牌
    return #ErrorType;
	};
  
  //三牌判断
  if (result.count[2] > 0) {
		//连牌判断
		if (result.count[2] > 1) {
			//变量定义
      let card = result.cards[2][0];
      let value = get_card_value(card);
      
      //错误过虑
		  if (value >= 15) return #ErrorType;

			//连牌判断
      for (i in Iter.range(1, result.count[2]-1)) {
        let card = result.cards[2][i*3];
				if (value != (get_card_value(card)+i)) return #ErrorType;
			};
    } else {
      if( num == 3 ) return #Triple;
    };

    //牌形判断
    if (result.count[2]*3 == num) return #TripleLine;
    if (result.count[2]*4 == num) return #TripleTakeSingle;
    if ((result.count[2]*5 == num) and (result.count[1] == result.count[2])) return #TripleTakeDouble;
	
		return #ErrorType;
	};
  
	//两张类型
	if (result.count[1] >= 3)
	{
    //变量定义
    let card = result.cards[1][0];
    let value = get_card_value(card);

		//错误过虑
		if (value >= 15) return #ErrorType;

		//连牌判断
    for (i in Iter.range(1, result.count[1]-1)) {
        let card = result.cards[1][i*2];
				if (value != (get_card_value(card)+i)) {
          return #ErrorType;
        }
    };

		//二连判断
		if ((result.count[1] * 2) == num) return #DoubleLine;

		return #ErrorType;
	};

	//单张判断
	if ((result.count[0] >= 5) and (result.count[0] == num))
	{
		//变量定义
    let card = result.cards[0][0];
    let value = get_card_value(card);

		//错误过虑
		if (value >= 15) return #Error;

		//连牌判断
    for (i in Iter.range(1, result.count[0]-1)) {
        let card = result.cards[0][i];
				if (value != (get_card_value(card)+i)) {
          return #Error;
        }
    };
		return #SingleLine;
	};
	return #Error;
};

// 比较两组牌，如果第二组比第一组大 就返回true，其他情况都返回false
public func compare(a_cards:[Card], b_cards:[Card]): Bool {
  let a = sort(a_cards);
  let b = sort(b_cards);
  let a_count = a.size();
  let b_count = a.size();
  
  //获取类型
	let a_type = get_card_type(a);
	let b_type = get_card_type(b);

	//类型判断
  switch(a_type,b_type) {
    case (#Error,_) {return false;};
    case (_,#Error) {return false;};
    case (_,#Rocket) {return true;};
    case (_,#Bomb) {
      if (a_type != #Bomb) {return true;};
    };
    case (#Bomb,_) {
      if (b_type != #Bomb) {return false;};
    };
    case (_,_) {
      if ((a_type != b_type) or (a_count != b_count)) {return false;};
    }
  };

  switch(b_type){
    case (#Single or #Double or #Triple or #SingleLine or #DoubleLine or #TripleLine or #Bomb) {
      let a_value = get_card_value(a[0]);
      let b_value = get_card_value(b[0]);
      return b_value > a_value;
    };
    case (#TripleTakeSingle or #TripleTakeDouble){
      //分析扑克
      let a_result: AnalyseResult = analyse(a);
      let b_result: AnalyseResult = analyse(b);

			//获取数值 
      let a_value = get_card_value(a_result.cards[2][0]);
      let b_value = get_card_value(b_result.cards[2][0]);
      return b_value > a_value;
    };
    case (#FourTakeSingle or #FourTakeDouble){
      //分析扑克
      let a_result: AnalyseResult = analyse(a);
      let b_result: AnalyseResult = analyse(b);

			//获取数值 
      let a_value = get_card_value(a_result.cards[3][0]);
      let b_value = get_card_value(b_result.cards[3][0]);
      return b_value > a_value;
    };
    case (#Error) {
      return false;
    };
    case (#Rocket) {
      return true;
    };
  };
	return false;
};


}
