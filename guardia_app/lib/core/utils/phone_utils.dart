import 'package:url_launcher/url_launcher.dart';

class PhoneUtils {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // Fallback or log error
        print('Could not launch $launchUri');
      }
    } catch (e) {
      print('Error launching phone call: $e');
    }
  }
}
