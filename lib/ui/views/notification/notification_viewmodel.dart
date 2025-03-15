// lib/ui/views/notification/notification_view_model.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:stacked/stacked.dart';
import 'package:aud_for_bank/app/app.locator.dart';
import 'package:aud_for_bank/services/notification_service.dart';

class NotificationViewModel extends ReactiveViewModel {
  final _notificationService = locator<NotificationService>();

  List<Uint8List> _atmImages = [];
  List<Uint8List> _bankImages = [];

  List<Uint8List> get atmImages => _atmImages;
  List<Uint8List> get bankImages => _bankImages;

  bool get isLoading => _atmImages.isEmpty && _bankImages.isEmpty;
  bool get hasImages => _atmImages.isNotEmpty || _bankImages.isNotEmpty;

  StreamSubscription? _atmSubscription;
  StreamSubscription? _bankSubscription;

  NotificationViewModel() {
    _loadStreams();
  }

  void _loadStreams() {
    _atmSubscription = _notificationService.getAtmImagesStream().listen(
          (base64Images) async {
        _atmImages = await _decodeImages(base64Images);
        notifyListeners();
      },
      onError: (e) {
        print('Error in ATM stream: $e');
      },
    );

    _bankSubscription = _notificationService.getBankImagesStream().listen(
          (base64Images) async {
        _bankImages = await _decodeImages(base64Images);
        notifyListeners();
      },
      onError: (e) {
        print('Error in Bank stream: $e');
      },
    );
  }

  Future<List<Uint8List>> _decodeImages(List<String> base64Images) async {
    final List<Uint8List> decodedImages = [];
    for (String base64String in base64Images) {
      try {
        final decoded = base64Decode(base64String);
        decodedImages.add(decoded);
      } catch (e) {
        print('Error decoding image: $e');
      }
    }
    return decodedImages;
  }

  @override
  void dispose() {
    _atmSubscription?.cancel();
    _bankSubscription?.cancel();
    super.dispose();
  }

  @override
  List<ListenableServiceMixin> get listenableServices => []; // No services needed here
}