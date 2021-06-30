class SearchResults<T> {
  SearchResults({this.suggestedItems, this.searchResults, this.query});

  List<T> suggestedItems;
  List<T> searchResults;
  String query;

  SearchResults.fromJson(Map json)
      : suggestedItems = json['suggested_items'],
        searchResults = json['search_results'],
        query = json['query'];

  Map<String, dynamic> toJson() => {
        'suggested_items': suggestedItems,
        'search_results': searchResults,
        'query': query,
      };
}
