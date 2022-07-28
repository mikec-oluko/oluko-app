class Country {
  String id;
  String name;
  List<String> states;

  Country({this.id, this.name, this.states});

  factory Country.fromJson(Map<String, dynamic> json) {
    final Country countryDto = Country(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
    return countryDto;
  }
}
