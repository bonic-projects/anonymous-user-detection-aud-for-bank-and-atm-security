import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/database_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/vediostream_service.dart';

class HomeViewModel extends BaseViewModel {
  final log = getLogger('homeviewmodel');
  final VediostreamService _mjpegService = VediostreamService();
  final NotificationService _notificationService = NotificationService();
  final DatabaseService _databaseService = DatabaseService();
  final NavigationService _navigationService = locator<NavigationService>();
  String? _streamUrl;
  String? _secondStreamUrl;
  String? _errorMessage;
  String? _savedIpAddress;
  String? _savedSecondIpAddress;

  String? get streamUrl => _streamUrl;
  String? get secondStreamUrl => _secondStreamUrl;
  String? get errorMessage => _errorMessage;
  String? get savedIpAddress => _savedIpAddress;
  String? get savedSecondIpAddress => _savedSecondIpAddress;

  NavigationService get navigationService => _navigationService;
  NotificationService get notificationService => _notificationService;

  // Fetch the MJPEG stream URL
  void startStream(String ipAddress) async {
    try {
      _errorMessage = null;
      _streamUrl = _mjpegService.getMjpegStreamUrl(ipAddress);
      log.i("$ipAddress");
      _databaseService.updateStreamStatus('bank', true);
      log.i('status updating');
      await _saveIpAddress(ipAddress, isSecondStream: false);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start stream: $e';
      notifyListeners();
    }
  }

  void start2Stream(String ipAddress) async {
    try {
      _errorMessage = null;
      _secondStreamUrl = _mjpegService.getMjpegStreamUrl2(ipAddress);
      log.i('$ipAddress');
      _databaseService.updateStreamStatus('atm', true);
      log.i("status updating");
      await _saveIpAddress(ipAddress, isSecondStream: true);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start stream: $e';
      notifyListeners();
    }
  }

  void stopFirstStream() {
    _streamUrl = null;
    _databaseService.updateStreamStatus('bank', false);
    notifyListeners();
  }

  void stopSecondStream() {
    _secondStreamUrl = null;
    _databaseService.updateStreamStatus('atm', false);
    notifyListeners();
  }

  Future<void> _saveIpAddress(String ipAddress,
      {bool isSecondStream = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (isSecondStream) {
      await prefs.setString('second_ip_address', ipAddress);
      _savedSecondIpAddress = ipAddress;
    } else {
      await prefs.setString('ip_address', ipAddress);
      _savedIpAddress = ipAddress;
    }
  }

  Future<void> loadSavedIpAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIpAddress = prefs.getString('ip_address');
    _savedSecondIpAddress = prefs.getString('second_ip_address');
    notifyListeners();
  }
}
