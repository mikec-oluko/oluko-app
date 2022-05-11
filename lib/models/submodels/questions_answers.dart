class QuestionAndAnswer {
  String question;
  String answer;

  QuestionAndAnswer({this.question, this.answer});

  factory QuestionAndAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAndAnswer(
      question: json['question']?.toString(),
      answer: json['answer']?.toString(),
    );
  }


}
