import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.router.dart';
import '../notification/notification_view.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _ip2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) async {
        await model.loadSavedIpAddresses();
        if (model.savedIpAddress != null) {
          _ipController.text = model.savedIpAddress!;
        }
        if (model.savedSecondIpAddress != null) {
          _ip2Controller.text = model.savedSecondIpAddress!;
        }
        model.notificationService.onNotificationTap.listen((RemoteMessage message) {
          print('Notification tapped: ${message.data}');
          model.navigationService.navigateTo(Routes.notificationView);
        });
      },
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black, // Black background for the entire screen
          appBar: AppBar(
            backgroundColor: Colors.black, // Black AppBar
            elevation: 0, // Flat design
            title: Text(
              'Surveillance',
              style: TextStyle(
                color: Colors.white, // White text
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  model.navigationService.navigateTo(
                    Routes.notificationView,
                    arguments: NotificationViewArguments(
                      arguments: {'type': 'atm', 'images': []},
                    ),
                  );
                },
                icon: Icon(Icons.notifications, color: Colors.white), // White icon
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bank Section
                  _buildSectionTitle('Bank'),
                  SizedBox(height: 10),
                  _buildTextField(_ipController, 'Enter IP Address'),
                  SizedBox(height: 20),
                  _buildStreamButtons(
                    model,
                    _ipController,
                    'Start Stream',
                    'Stop Bank Stream',
                    model.startStream,
                    model.stopFirstStream,
                    model.streamUrl,
                  ),
                  SizedBox(height: 10),
                  if (model.streamUrl != null)
                    _buildStreamViewer(model.streamUrl!),

                  Divider(color: Colors.grey[800], height: 30), // Gray divider

                  // ATM Section
                  _buildSectionTitle('ATM'),
                  SizedBox(height: 10),
                  _buildTextField(_ip2Controller, 'Enter Second IP Address'),
                  SizedBox(height: 20),
                  _buildStreamButtons(
                    model,
                    _ip2Controller,
                    'Start Stream',
                    'Stop ATM Stream',
                    model.start2Stream,
                    model.stopSecondStream,
                    model.secondStreamUrl,
                  ),
                  SizedBox(height: 10),
                  if (model.secondStreamUrl != null)
                    _buildStreamViewer(model.secondStreamUrl!),

                  // Error Message
                  if (model.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        model.errorMessage!,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method for section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white, // White title
      ),
    );
  }

  // Helper method for text fields
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]), // Light gray label
        filled: true,
        fillColor: Colors.grey[900], // Dark gray background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: TextStyle(color: Colors.white), // White text input
      keyboardType: TextInputType.number,
    );
  }

  // Helper method for stream buttons
  Widget _buildStreamButtons(
      HomeViewModel model,
      TextEditingController controller,
      String startText,
      String stopText,
      Function(String) startCallback,
      Function() stopCallback,
      String? streamUrl,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            final ipAddress = controller.text.trim();
            if (ipAddress.isNotEmpty) {
              startCallback(ipAddress);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // White button
            foregroundColor: Colors.black, // Black text/icon
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(startText, style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: streamUrl != null ? stopCallback : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900], // Dark gray button
            foregroundColor: Colors.white, // White text/icon
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(stopText, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  // Helper method for stream viewer
  Widget _buildStreamViewer(String streamUrl) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: MJPEGStreamScreen(
        streamUrl: streamUrl,
        showLiveIcon: true,
        height: 300,
        width: 250,
      ),
    );
  }
}