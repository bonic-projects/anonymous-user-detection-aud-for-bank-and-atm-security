import 'package:aud_for_bank/app/app.logger.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class VediostreamService {
  final log = getLogger('vediostream');

  // Fetch the MJPEG stream URL
  String getMjpegStreamUrl(String ipAddress) {
    return 'http://$ipAddress/stream'; // Replace with your MJPEG stream endpoint
  }

  String getMjpegStreamUrl2(String ipAddress) {
    return 'http://$ipAddress/stream'; // Replace with your MJPEG stream endpoint
  }
}
