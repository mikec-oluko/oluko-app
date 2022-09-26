import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  static Future<void> openNewUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
