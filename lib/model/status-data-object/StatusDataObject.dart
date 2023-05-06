enum StatusCode {
  _,
  loading,
  partialDataLoading,
  missingInputValues,
  notSet,
  error,
  completeData
}

class FeedbackStatus {
  StatusCode code;
  String? message;
  String? propertyName;

  static final List<StatusCode> _jsEnumIndex = [
    StatusCode._,
    StatusCode.loading, //LOADING 1,
    StatusCode.partialDataLoading, //PARTIAL_DATA_LOADING 2,
    // from here on data won't load anymore
    StatusCode.missingInputValues, // MISSING_INPUT_VALUES 3,
    StatusCode.notSet, //NOT_SET 4,
    StatusCode.error, //ERROR 5,
    //
    StatusCode.completeData, //COMPLETE_DATA 6,
  ];

  FeedbackStatus(this.code, this.message, {String? this.propertyName});

  static List<FeedbackStatus> fromJson<T>(List<dynamic> json) {
    if(json == null){
      return [];
    }

    return json.map((dynamic e) {
      // if(e is List)
      try {
        if(e is Map && e.isEmpty) {
          return FeedbackStatus(StatusCode.completeData, '');
        }
      return FeedbackStatus(toStatusCode(e['code']), e['message'],
          propertyName: e['propertyName']);
      }catch(err){
        print("StatusDataObject ERROR PARSING JSON=${e['code']} v=${e['message']}");
        return FeedbackStatus(StatusCode.completeData, 'failed to parse');
      }
    }).toList();
  }

  static StatusCode toStatusCode(int jsEnumIndex) {
    return _jsEnumIndex[jsEnumIndex];
  }
}

typedef ParseFn<T> = T Function(dynamic);
typedef ParseListFn<T> = List<T> Function(dynamic);

ParseListFn<StatusDataObject<T>> getParsableListFn<T>(ParseFn<T> fn) {
  var itemParser = (accFdm) => StatusDataObject.fromJson(accFdm, fn);

  ParseListFn<StatusDataObject<T>> parsableFn =
      (accList) => List<StatusDataObject<T>>.from(accList.map(itemParser));
  return parsableFn;
}

String? getFdmListMessage(
    StatusDataObject<List> list, String itemName, String loading) {
  String? message;
  if (list.hasStatus(StatusCode.completeData) && list.data.isEmpty) {
    message = 'No ${itemName}s found.';
  }
  if (list.hasStatus(StatusCode.loading)) {
    message = '${loading} ${itemName}...';
  }
  if (list.hasStatus(StatusCode.error)) {
    message = 'Error ${loading} ${itemName}s (${list.statusList[0].message})';
  }
  return message;
}

class StatusDataObject<T> {
  T data;
  List<FeedbackStatus> statusList;

  StatusDataObject(this.data, this.statusList);

  static StatusDataObject<T>? fromJson<T>(dynamic json, ParseFn<T> parsableFn) {
    if (json == null || (json is Map && !json.containsKey('data'))) {
      return null;
    }
    T data = parsableFn(json['data']);
    List<FeedbackStatus> status = FeedbackStatus.fromJson(json['_status']);
    return StatusDataObject(data, status);
  }

  static StatusDataObject<List<T>> fromJsonList<T>(
      dynamic json, ParseListFn<T> parsableListFn) {
    List<T> data = parsableListFn(json['data']);
    List<FeedbackStatus> status = FeedbackStatus.fromJson(json['_status']);
    return StatusDataObject(data, status);
  }

  bool hasStatus(StatusCode code, {String? propertyName}) {
    return statusList.indexWhere((element) {
          return element.code == code &&
              (element.propertyName == propertyName);
        }) !=
        -1;
  }
}
