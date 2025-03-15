import 'package:aud_for_bank/app/app.logger.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final log = getLogger('database service');
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> updateStreamStatus(String streamType, bool isActive) async {
    try {
      await _database.child('streams').child(streamType).set(isActive);
      log.i("staus:$isActive");
    } catch (e) {
      log.e('Error updating stream status: $e');
    }
  }

  Stream<DatabaseEvent> getStreamStatus(String streamType) {
    return _database.child('streams').child(streamType).onValue;
  }

  // Method to get all streams
  Stream<DatabaseEvent> getAllStreams() {
    return _database.child('streams').onValue;
  }
}
