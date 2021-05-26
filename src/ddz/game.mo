import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Deque "mo:base/Deque";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import Time "mo:base/Time"
import Poker "poker";
import Player "player";
import Massage "message";
import Timer "timer";

module {

public type Result<T,E> = Result.Result<T,E>;
public type Card = Poker.Card;
public type CardType = Poker.CardType;
public type TableMsg = Massage.TableMsg;
public type TableId = Massage.TableId;
public type SeatId = Massage.SeatId;
public type PlayerId = Player.PlayerId;
public type PlayerState = Player.PlayerState;

public type GameError = {
  #PlayerNotRegistered;
  #TableNoFreeSeat;
  #PlayerNotFound;
  #TableNotFound;
  #PlayerNotInTheTable;
  #NotTurnYou;
  #CardTypeError;
  #CardLessLast;
};

public type GameState = {
  #Wait;
  #Ready;
  #Call;
  #Play;
  #Over;
};

public class Table(id: TableId) {
  let m_id: TableId = id;
  //let level = _level;
  let m_base_score = 1;
  let m_max_seat = 3;
  let m_players: [var ?PlayerState] = [var null, null, null];
  var m_cards: [[Card]] = [];

  var m_call_status = false;
  var m_call_score = 0;
  var m_first_seat = 0;
  var m_cur_seat = 0;
  var m_banker_seat = 0;
  var m_bomb_count = 0;

  var m_last_seat = 0;
  var m_last_cards:[Card] = [];
  var m_turn_over = false;

  //用来判断春天和反春天的出牌次数记录
  var m_out_times:[var Nat] = [var 0, 0, 0];

  var m_seat_state: [var GameState] = [var #Wait, #Wait, #Wait];
  var m_game_state = #Wait;

  
  var m_msg_queue: [var Deque.Deque<TableMsg>] = [var Deque.empty<TableMsg>(), Deque.empty<TableMsg>(), Deque.empty<TableMsg>()];
  var m_rand_poker: Poker.RandomPoker = Poker.RandomPoker();
  let m_timer: Timer.Timer = Timer.Timer();

  func add_user_msg(seat: SeatId, msg: TableMsg){
    m_msg_queue[seat] := Deque.pushFront(m_msg_queue[seat], msg);
  };

  func add_table_msg(sid: SeatId, msg: TableMsg) {
    for (i in Iter.range(0, m_max_seat-1)){
      //if(i != sid){
        m_msg_queue[sid] := Deque.pushFront(m_msg_queue[sid], msg);
      //};
    };
  };

  func get_seat_msg(sid: SeatId): TableMsg {
    switch(Deque.popFront(m_msg_queue[sid])){
      case null { return #NoneMsg({seat=sid;}); };
        case (msg, queue)  {
          m_msg_queue[sid] := queue;
          return msg;
        };
    };
  };

  public func get_id(): TableId {
    m_id
  };

  // 判断所有用户在同一个状态，并返回该状态
  func is_sync(s: GameState): Bool {
    (m_seat_state[0] == s) and (m_seat_state[0] == m_seat_state[1]) and (m_seat_state[1] == m_seat_state[2])
  };

  // 用户id和座位号参数检查
  public func get_seat_id(uid: PlayerId): ?SeatId {
    for (i in Iter.range(0, m_max_seat-1)){
      switch(m_players[i]){
        case null {};
        case (?player)  {
          if(uid == player.id){
            return ?i;
          };
        };
      };
    };
    null
  };

  public func get_free_seat(): ?SeatId{
    for (i in Iter.range(0, m_max_seat-1)){
      switch(m_players[i]){
        case null { return ?i; };
        case (_)  {};
      };
    };
    null
  };

  public func is_wait(): Bool{
    for (i in Iter.range(0, m_max_seat-1)){
      switch(m_players[i]){
        case null { return true; };
        case (_)  {};
      };
    };
    false
  };

  // 判断是否一个有效的桌子，如果有玩家，并长时间没有心跳消息，说明这个桌子失效了，不能让玩家加入
  public func is_valid(): Bool{
    false
  };

  // 游戏状态切换
  func change_state(state: GameState){
    game_state = state;
    for (i in Iter.range(0, m_max_seat-1)){
      m_seat_state[i] := state;
    };
  };

  // 更新定时器
  func update_time(){
    let now = Time.now();
  };

  // 加入游戏
  public func join(pid: PlayerId): Result<SeatId, GameError> {
    switch (get_seat_id(pid)) {
      case null { 
        switch(get_free_seat(), Player.get_player_by_id(pid)){
          case (?sid, ?user) {
            players[sid] := ?user;
            add_table_msg(sid,  #JoinMsg({seat = sid; player = user; }));
            //seat_state[seat] := #Wait;
            return #ok(sid);
          };
          case (null, _) { return #err(#TableNoFreeSeat); };
          case (_, null) { return #err(#PlayerNotRegistered); };
        };
      };
      case (?sid) {
        //let tid: TableId = t.get_id();
        return #ok(sid);
      };
    };
  };

  public func leave(pid: PlayerId): Result<SeatId, GameError> {
    switch (get_seat_id(pid)) {
      case null { 
        return #err(#PlayerNotInTheTable);
      };
      case (?sid) {
        players[seat] := null;
        //let tid: TableId = t.get_id();
        if (game_state != #Wait){
          over_process();
        };
        add_table_msg(sid,  #LeaveMsg({seat = sid;}));
        return #ok(sid);
      };
    };
  };

  public func ready(pid: PlayerId): Result<SeatId, GameError> {
    switch (get_seat_id(pid)) {
      case null { 
        return #err(#PlayerNotInTheTable);
      };
      case (?sid) {
        m_seat_state[sid] := #Ready;
        if (is_sync(#Ready)){
          deal_process();
        };
        
        add_table_msg(sid,  #ReadyMsg({seat = sid;}));
        //let tid: TableId = t.get_id();
        return #ok(sid);
      };
    };
  };

  // 获取消息
  public func get_msg(pid: PlayerId): Result<Msg, GameError>{
    switch (get_seat_id(pid)) {
      case null { 
        return #err(#PlayerNotInTheTable); 
      };
      case (?sid) {
        // 根据状态创建消息
        return get_seat_msg(sid);
      };
    };
    // 判断入参是否合法
  };

  // 叫分
  public func call(player: PlayerId, flag: Bool): Result<SeatId, GameError> {
    // 判断入参是否合法
    switch (t.get_seat_id(player)) {
      case null { 
        return #err(#PlayerNotInTheTable); 
      };
      case (?sid) {
        var is_start = false;
        if(sid != m_cur_seat){
          return #err(#NotTurnYou);
        };

        if (flag) {
          m_call_score = m_call_score + 1;
          m_banker_seat = sid;
        };

        if (m_call_status and m_cur_seat == m_first_seat){
          is_start = true;
          // 没人叫分
          if(m_call_score == 0){
            m_call_score = 1;
            m_banker_seat = m_first_seat;
          };
        };

        m_call_status = true;

        m_cur_seat = (sid + 1) % m_max_seat;

        add_table_msg(sid,  #CallMsg({cur_seat = m_cur_seat; is_call = flag; cur_score = m_call_score;}));

        if (is_start) {
          //发送底牌，游戏开始
          //m_last_seat = m_banker_seat;
          m_cur_seat = m_banker_seat;
          add_table_msg(sid,  #BankerMsg({cur_seat = m_cur_seat; banker_seat = m_banker_seat; banker_score = m_call_score; cards = m_cards[3];}));
          m_cards[m_banker_seat] := Array.append(m_cards[m_banker_seat], m_cards[3]);
          //需要启动定时检测出牌超时
        };

        //需要重置叫分定时器

        //let tid: TableId = t.get_id();
        return #ok(m_cur_seat);
      };
    };
  };


  // 打牌
  public func out(player: PlayerId, cards: [Card]): Result<SeatId, GameError> {
    // 判断入参是否合法
    switch (get_seat_id(pid)) {
      case null { 
        return #err(#PlayerNotInTheTable);
      };
      case (?sid) {
        var is_over = false;
        if(sid != m_cur_seat){
          return #err(#NotTurnYou);
        };

        // 获取并判断牌类型是否合法
        let card_type = Poker.get_card_type(cards);
        if (card_type == #ErrorType){
          return #err(#CardTypeError);
        };

        // 判断是吃牌还是主动出牌
        if(not m_turn_over){
          // 如果是吃牌，就比较牌的大小
          if(not Poker.compare(cards, m_last_cards)){
            return #err(#CardLessLast);
          };
        };

        // 正常出牌，删除扑克
        m_cards[sid] := Poker.remove(m_cards[sid], cards);

        // 炸弹和火箭，积分翻倍
        if (card_type == #Bomb or card_type == #Rocket){
          m_bomb_count = m_bomb_count + 1;
        };

        // 出牌不是火箭，切换用户
        if (card_type == #Rocket){
          m_turn_over = true;
        }
        else {
          m_turn_over = false;
          m_cur_seat = (m_cur_seat + 1) % m_max_seat;
        }

        // 设置变量
        m_last_seat = sid;
        m_last_cards := cards;
        m_out_times[sid] = m_out_times[sid] + 1;

        // 发送出牌消息
        add_table_msg(sid,  #OutMsg({cur_seat = m_cur_seat; out_seat = sid; cards = cards;}));

        // 判断是否出完牌,如果还有手牌，直接返回
        if (m_cards[sid].size() > 0){
          return #ok(m_cur_seat);
        };

        over_process(sid);

        return #ok(m_cur_seat);
      };
    };
  };

  // 放弃牌
  public func pass(player: PlayerId): Result<SeatId, GameError> {
    // 判断入参是否合法
    switch (get_seat_id(pid)) {
      case null { 
        return #err(#PlayerNotInTheTable);
      };
      case (?sid) {
        if(sid != m_cur_seat){
          return #err(#NotTurnYou);
        };

        m_cur_seat = (sid + 1) % m_max_seat;
        if (m_cur_seat == m_last_seat){
          m_turn_over = true;
        };

        // 发送消息
        add_table_msg(sid, #PassMsg({cur_seat = m_cur_seat; pass_seat = sid;}));
        return #ok(m_cur_seat);
      };
    };
  };

  // 发牌
  func deal_process() {

    m_call_status = false;
    cards := Poker.dispatch(m_rand_poker.get());
    
    // 根据第一张扑克牌计算一个随机座位
    m_cur_seat = Poker.get_value(cards[0][0]) % m_max_seat;
    m_first_seat = m_cur_seat;
    m_banker_seat = m_cur_seat;
    m_call_score = 0;

    //生成消息，并添加到用户的消息队列中
    for (i in Iter.range(0, m_max_seat-1)){
      add_user_msg(i,  #StartMsg({cur_seat = m_cur_seat; cards = m_cards[i]}));
    };
    change_state(#Call);
    
    //需要启动定时检测叫分超时
    m_timer.start()
  };
  
  // 开始打牌
  func start_process() {
    m_turn_over = true;
    m_out_times := [var 0, 0, 0];
    m_last_cards := [];
    change_state(#Play);
    //需要启动定时检测出牌超时
  };

  // 游戏结束
  func over_process(seat: SeatId) {

    // 计算结算分数
    var all_scores:[var Nat] = [var 0, 0, 0];
    var score = m_base_score;
    for (i in Iter.range(1, m_call_score)){
      score = score * 2;
    };
    
    for (i in Iter.range(1, m_bomb_count)){
      score = score * 2;
    };

    // 春天判断
    var is_spring = false;
    var is_antispring = false;
    if(m_banker_seat == seat) {
      let s1 = (seat + 1) % m_max_seat;
      let s2 = (seat + 2) % m_max_seat;
      if(m_out_times[s1] == 0 and m_out_times[s2] == 0){
        is_spring = true;
        score = score * 2;
      };

      score = score * 2;
      // 更新用户积分
      for (i in Iter.range(1, m_max_seat - 1)){
        if(i == seat){
          all_scores[i] = score;
          m_players[i].Score = m_players[i].Score + score;
        };
      };
    }
    else{
      if (m_out_times[m_banker_seat] == 1){
        is_antispring = true;
        score = score * 2;
      };
      
      // 更新用户积分
      for (i in Iter.range(1, m_max_seat - 1)){
        if(i != m_banker_seat){
          all_scores[i] = score;
          m_players[i].Score = m_players[i].Score + score;
        };
      };
    };

    add_table_msg(sid, #PassMsg({scores = all_scores; spring = is_spring; antispring = is_antispring; call_score = m_call_score; boom_count = m_bomb_count;}));

  };

  // 重置游戏
  func reset(){
    cards := [];
  };
  
};

public class Room() {
  var last_id: TableId = 0;
  // 将游戏实例保存到map里
  let m_table_map: HashMap.HashMap<TableId, Table> = HashMap.HashMap<TableId, Table>(100, func (x, y) { x == y }, Hash.hash);
  let m_id_map: HashMap.HashMap<PlayerId, TableId> = HashMap.HashMap<PlayerId, TableId>(100, func (x, y) { x == y }, Principal.hash);

  func get_table_id(id: PlayerId): ?TableId{
    m_id_map.get(id)
  };

  func get_table(id: TableId): ?Table{
    m_table_map.get(tid)
  };

  func get_table_by_player(id: PlayerId): ?Table{
    switch (id_map.get(id)) {
      case null { null };
      case (?tid) { table_map.get(tid) };
    }
  };

  // 如果返回大于等于0的值，说明加入成功，返回-1 加入失败
  public func auto_join(uid: PlayerId): Result<SeatId, GameError> {
    // 判断TableId是否为0， 如果是0，就自动分配一个游戏
    switch (get_table_by_player(uid)) {
      case null {
        Debug.print("Not in table");
        // 检查现有的游戏列表是否满员，如果有空闲位置，就让新用户进入
        for((_, t) in m_table_map.entries()){
          if(t.is_wait()) {
            m_id_map.put(uid, last_id);
            return t.join(uid);
          };
        };
        
        Debug.print("No empty table");
        // 如果没有现有的游戏可以加入，就新创建一个游戏
        last_id += 1;
        let t = Table(last_id);
        m_table_map.put(last_id, t);
        m_id_map.put(uid, last_id);
        return t.join(uid);
      };
      case (?t) {
        Debug.print("player in a table");
        return t.join(uid);
      };
    };
  };

  public func leave(uid: PlayerId): Result<SeatId, GameError> {
    switch (get_table_by_player(tid)) {
      case null {
        Debug.print("Not in table");
        return #err(#PlayerNotInTheTable);
      };
      case (?table) {
        //Debug.print("player in a table");
        // 需要删除map信息
        m_id_map.delete(uid);
        return table.leave(uid);
      };
    };
  };

  public func ready(uid: PlayerId): Result<SeatId, GameError> {
    switch (get_table_by_player(tid)) {
      case null {
        Debug.print("Not in table");
        return #err(#PlayerNotInTheTable);
      };
      case (?table) {
        //Debug.print("player in a table");
        return table.ready(uid);
      };
    };
  };

  public func get_msg(uid: PlayerId): Result<Massage.Msg, GameError> {
    switch (get_table_by_player(uid)) {
      case null {
        Debug.print("Not in table");
        return #err(#PlayerNotInTheTable);
      };
      case (?table) {
        Debug.print("player in a table");
        return table.get_msg(uid);
      };
    };
  };

  // 叫分
  public func call(uid: PlayerId, flag: Bool): Result<SeatId, GameError> {
    switch (get_table_by_player(uid)) {
      case null {
        Debug.print("Not in table");
        return #err(#PlayerNotInTheTable);
      };
      case (?table) {
        Debug.print("player in a table");
        return table.call(uid, flag);
      };
    };
  };

  // 打牌
  public func out(uid: PlayerId, cards: [Card]): Result<SeatId, GameError>  {
    switch (get_table_by_player(uid)) {
      case null {
        Debug.print("Not in table");
        return #err(#PlayerNotInTheTable);
      };
      case (?table) {
        Debug.print("player in a table");
        return table.out(uid, cards);
      };
    };
  };

  // pass
  public func pass(uid: PlayerId): Result<SeatId, GameError> {
    switch (get_table_by_player(uid)) {
      case null {
        Debug.print("Not in table");
        return #err(#PlayerNotInTheTable);
      };
      case (?table) {
        Debug.print("player in a table");
        return table.pass(uid, flag);
      };
    };
  };
  
};
}