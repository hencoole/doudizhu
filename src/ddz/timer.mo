import Debug "mo:base/Debug";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";


module {
public type TimerId = Nat;

type TimerData = {
  end_time: Time.Time;
  //interval: Nat;
  callback: () -> ();
};

public class Timer() {
  var m_last_id: TimerId = 0;
  let m_timer_map: HashMap.HashMap<TimerId, TimerData> = HashMap.HashMap<TimerId, TimerData>(100, func (x, y) { x == y }, Hash.hash);

  public func start(ms: Int, f: () -> ()): TimerId {
    let now = Time.now()/1000000;
    
    Debug.print("set time:" # Int.toText(now));
    m_last_id += 1;
    m_timer_map.put(m_last_id, {end_time = now + ms; callback=f;});
    m_last_id 
  };

  public func stop(id: TimerId) {
    m_timer_map.delete(id);
  };

  public func clear(id: TimerId) {
    for((id, _) in m_timer_map.entries()){
      m_timer_map.delete(id);
    };
  };

  public func update() {
    let now = Time.now()/1000000;
    Debug.print("update time:" # Int.toText(now));
    for((id, t) in m_timer_map.entries()){
      if(now > t.end_time) {
        t.callback();
        m_timer_map.delete(id);
      };
    };
  };
};

};