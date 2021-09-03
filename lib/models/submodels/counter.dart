class Counter {
  int round;
  int set;
  int counter;

  Counter({this.round, this.set, this.counter});

  factory Counter.fromJson(Map<String, dynamic> json) {
    return Counter(
      round: json['round'],
      set: json['set'],
      counter: json['counter'],
    );
  }

  Map<String, dynamic> toJson() => {
        'round': round,
        'set': set,
        'counter': counter,
      };
}
