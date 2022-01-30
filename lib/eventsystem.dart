class EventSystem {
  Map<String, List<Function>> map = {};

  void addEvent(String eventName, Function event) {
    if (!map.containsKey(eventName))
      map[eventName] = [event];
    else
      map[eventName]!.add(event);
  }

  void removeEvent(Function event) {
    for (List l in map.values) {
      if (l.contains(event)) l.remove(event);
    }
  }

  void call(String name, [dynamic arg]) {
    if (map[name] == null) {
      //print("ERROR: $name is null! Could not call the event");
      return;
    }
    //print("Event $name was called: found ${map[name].length} events!");
    for (Function f in map[name]!) {
      if (arg != null)
        f(arg);
      else
        f();
    }
  }
}
