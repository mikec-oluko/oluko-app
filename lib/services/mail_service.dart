import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

class MailService {
  static void sendContactUsMail(String username, String email, String message, String phone) {
    CollectionReference reference = FirebaseFirestore.instance.collection('emails');
    Map<String, dynamic> mail = {
      'projectId': GlobalConfiguration().getString('projectId'),
      'template': {
        'data': {'userName': username, 'email': email, 'message': '$message - Phone: $phone - Email: $email', 'from': email},
        'name': '${GlobalConfiguration().getString('projectId')}-${emailTemplates[EmailTemplateEnum.contactUs]}',
      },
      'to': mailsEnum[MailEnum.support],
      'replyTo': email,
    };
    reference.add(mail);
  }
}
