import 'package:oluko_app/helpers/enum_collection.dart';

class QuestionAndAnswer {
  String question;
  String answer;
  FAQCategoriesEnum category;

  QuestionAndAnswer({this.question, this.answer,this.category});

  factory QuestionAndAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAndAnswer(
      question: json['question']?.toString(),
      answer: json['answer']?.toString(),
      category: FAQCategoriesEnum.values[json['category'] as int]
    );
  }


}
