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
    return json.map((dynamic e) {
      // try {
        return FeedbackStatus(
            toStatusCode(e['code']), e['message'],
            propertyName: e['propertyName']);
      // }catch(err){
      //   print("ERROR PARSING JSON=${e['code']}");
      //   return FeedbackStatus(StatusCode.completeData, 'failed to parse');
      // }
    }).toList();
  }

  static StatusCode toStatusCode(int jsEnumIndex) {
    return _jsEnumIndex[jsEnumIndex];
  }
}

typedef ParseFn<T> = T Function(dynamic);
typedef ParseListFn<T> = List<T> Function(dynamic);

ParseListFn<FeedbackDataModel<T>> getParsableListFn<T>(ParseFn<T> fn) {
  var itemParser = (accFdm) => FeedbackDataModel.fromJson(accFdm, fn);

  ParseListFn<FeedbackDataModel<T>> parsableFn =
      (accList) => List<FeedbackDataModel<T>>.from(accList.map(itemParser));
  return parsableFn;
}

String? getFdmListMessage(FeedbackDataModel<List> list, String itemName) {
  String? message = null;
  if (list
      .hasStatus(StatusCode.completeData)
      && list.data.isEmpty
  ){
    message = 'No ${itemName}s found.';
  }
  if (list
      .hasStatus(StatusCode.loading)){
    message = 'Loading ${itemName}s...';
  }
  if (list
      .hasStatus(StatusCode.error)){
    message = 'Error loading ${itemName}s (${list.statusList[0].message})';
  }
  return message;
}

class FeedbackDataModel<T> {
  T data;
  List<FeedbackStatus> statusList;

  FeedbackDataModel(this.data, this.statusList);

  static FeedbackDataModel<T>? fromJson<T>(
      dynamic json, ParseFn<T> parsableFn) {
    if (json == null) {
      return null;
    }
    T data = parsableFn(json['data']);
    List<FeedbackStatus> status = FeedbackStatus.fromJson(json['_status']);
    return FeedbackDataModel(data, status);
  }

  static FeedbackDataModel<List<T>> fromJsonList<T>(
      dynamic json, ParseListFn<T> parsableListFn) {
    List<T> data = parsableListFn(json['data']);
    List<FeedbackStatus> status = FeedbackStatus.fromJson(json['_status']);
    return FeedbackDataModel(data, status);
  }

  bool hasStatus(StatusCode code, {String? propertyName}) {
    return statusList.indexWhere((element) {
          return element.code == code && (propertyName == null
              ? true
              : element.propertyName == propertyName);
        }) !=
        -1;
  }
}
