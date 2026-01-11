class SearchResult<T> {
  List<T>? result;
  int? count;

  SearchResult({this.result, this.count});

  SearchResult.fromJson(Map<String, dynamic> json, Function fromJsonModel) {
    var resultData = json['resultList'] ?? json['result'];

    if (resultData != null) {
      result = <T>[];
      resultData.forEach((v) {
        result!.add(fromJsonModel(v));
      });
    }
    count = json['count'];
  }
}
