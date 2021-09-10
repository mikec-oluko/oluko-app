class Counter {
  int round;
  int set;
  int counter;

  Counter({this.round, this.set, this.counter});

  factory Counter.fromJson(Map<String, dynamic> json) {
    return Counter(
      round: int.tryParse(json['round'].toString()),
      set: int.tryParse(json['set'].toString()),
      counter: int.tryParse(json['counter'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'round': round,
        'set': set,
        'counter': counter,
      };
}
