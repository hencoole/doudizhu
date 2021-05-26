
import HashMap "mo:base/HashMap";
import Player "player";
import Massage "massage";
import Game "game";
import Types "types";

module {

Public class Manager() {
  // 将游戏实例保存到map里
  var game_map: HashMap.HashMap<Massage.GameId, Game.GameTable>;
  var last_id: Massage.GameId = 0;
  let id_map: HashMap.HashMap<PlayerId, Massage.GameId>;

  func alloc_gameid(): Massage.GameId{
    last_id++;
    last_id
  };

  func create_game(): Massage.GameId{

  };

  func destroy_game(gid: Massage.GameId){

  };

  func exsit_game(gid: Massage.GameId): Bool{

  };

  public func get_game_id(id: Player.PlayerId): ?Massage.GameId{
    id_map.get(id)
  };

  func get_game(id: Massage.GameId): ?Game.GameTable{
    game_map.get(id)
  };

  func get_wait_game(id: Massage.GameId): ?Game.GameTable{
    game_map.get(id)
  };
  func get_game_by_player(id: Massage.GameId): ?Game.GameTable{
    switch (get_game_id(uid)) {
      case null { null };
      case (?gid) { get_game(gid) };
    }
  };

  public func auto_join(uid: Player.PlayerId): Bool{
    // 判断GameId是否为0， 如果是0，就自动分配一个游戏
    switch (get_game_by_player(id)) {
      case null {
        // 检查现有的游戏列表是否满员，如果有空闲位置，就让新用户进入
        // 如果没有现有的游戏可以加入，就新创建一个游戏 
      };
      case (?game) { true };
    }
    false
  };

  public func join(uid: Player.PlayerId, gid: Massage.GameId): Massage.GameId{
   
  };

  public func ready(player: PlayerId){

  };
  
  public func call(player: PlayerId): Bool {

  };
  
  public func play(player: PlayerId): Bool {

  };
  
  public func get_msg(uid: Player.PlayerId){

  };
  
  public func leave(uid: Player.PlayerId){

  };
};


}