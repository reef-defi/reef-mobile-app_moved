import 'dart:convert';

class WsConnState {
  bool isConnected;
  WsConnStatus statusValue;
  WsConnStatus? lastErr;

  WsConnState(this.isConnected, this.statusValue, {this.lastErr});

  static WsConnState? fromJson(dynamic json) {
    try {
      if (json is Map) {
        var isConnected = json['isConnected'];
        var lastErr = json['lastErr']!=null?WsConnStatus.fromJson(json['lastErr']):null;
        return WsConnState(isConnected, WsConnStatus.fromJson(json['status']),
            lastErr: lastErr);
      }
    } catch (e) {
      print('ERROR parsing WsConnState $e');
    }
    return null;
  }

  @override
  String toString() {
    var ret = new Map();
    ret['isConnected'] = isConnected;
    ret['status'] = statusValue.toString();
    ret['lastErr'] = lastErr.toString();
    return const JsonEncoder().convert(ret);
  }
}

class WsConnStatus {
  WsConnStatusVal value;
  int timestamp;
  dynamic data;

  WsConnStatus(this.value, this.timestamp, {this.data});

  static WsConnStatus fromJson(dynamic json) {
    // if(json==null) {
    //   return null;
    // }
    var value = WsConnStatusVal.from(json['value']);
    var ts = json['timestamp'] ?? 0;
    return WsConnStatus(value, ts, data: json['data']);
  }

  @override
  String toString() {
    var ret = new Map();
    ret['value'] = value.toString();
    ret['timestamp'] = timestamp;
    ret['data'] = data;
    return const JsonEncoder().convert(ret);
  }
}

enum WsConnStatusVal {
  error,
  connecting,
  connected,
  disconnected,
  unknown;

  static WsConnStatusVal from(String val) {
    try {
      return WsConnStatusVal.values.firstWhere((v) => v.toShortString() == val);
    } catch (e) {
      return WsConnStatusVal.unknown;
    }
  }
}

extension ParseToString on WsConnStatusVal {
  String toShortString() {
    return toString().split('.').last;
  }
}
