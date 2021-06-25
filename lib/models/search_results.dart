
class SearchResults<T> {
  SearchResults({this.suggestedItems, this.query});

  List<T> suggestedItems;
  String query;

  SearchResults.fromJson(Map json)
      : suggestedItems = json['suggested_items'],
        query = json['query'];

  Map<String, dynamic> toJson() => {
        'suggested_items': suggestedItems,
        'query': query,
      };
}
