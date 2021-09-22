class Counter {
  int round;
  int counter;

  Counter({this.round, this.counter});

  factory Counter.fromJson(Map<String, dynamic> json) {
    return Counter(
      round: int.tryParse(json['round'].toString()),
      counter: int.tryParse(json['counter'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'round': round,
        'counter': counter,
      };
}
