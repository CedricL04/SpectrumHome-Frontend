import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/utils.dart';

class SyncedValue<T> {
  final bool public;
  final String path;

  T? _value;
  T? get vaule => _value;

  SyncedValue(this.path, {this.public = false}) {
    Map<String, dynamic>? json =
        public ? theme.server.publicData : theme.server.userData;
    var value = Utils.load(json, path);

    if (value is T) _value = value;
  }

  Future set(T value) async {
    this._value = value;
    await theme.server.syncedUpdate(value, path, public: public);
  }

  // Future<T> sync([T def]) async {
  //   var val = await theme.server.sendRequest({
  //     "type": "storage",
  //     "action": "load",
  //     "values": {"public": public, "path": path}
  //   });
  //   _value = val["data"] ?? def;
  //   return _value;
  // }
}

class SyncedCollectionValue<T> extends SyncedValue<List> {
  final T Function(String) fromStr;
  final String Function(T) toStr;

  SyncedCollectionValue(String path,
      {required this.fromStr, required this.toStr, bool public = false})
      : super(path, public: public);

  List<T> get converted => (vaule ?? []).map((s) => fromStr(s)).toList();

  Future setConverted(List<T> value) {
    return set(value.map(toStr).toList());
  }
}
