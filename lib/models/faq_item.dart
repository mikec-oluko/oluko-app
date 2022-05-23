import 'package:oluko_app/helpers/enum_collection.dart';

class FAQItem {
  String question;
  String answer;
  FAQCategoriesEnum category;

  FAQItem({this.question, this.answer, this.category});

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
        question: json['question']?.toString(),
        answer: json['answer']?.toString(),
        category: FAQCategoriesEnum.values[json['category'] as int]);
  }
}
