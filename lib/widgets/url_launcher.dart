import 'package:url_launcher/url_launcher.dart';

class IconNavigationHandler {
  void navigateTo(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
