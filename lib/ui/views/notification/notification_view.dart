import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'notification_viewmodel.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationViewModel>.reactive(
      viewModelBuilder: () => NotificationViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.black, // Black background
        appBar: AppBar(
          backgroundColor: Colors.black, // Black AppBar
          elevation: 0, // Flat design
          title: const Text(
            'Latest Threat Images',
            style: TextStyle(
              color: Colors.white, // White title
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        ),
        body: _buildBody(context, model),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationViewModel model) {
    if (model.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White spinner
        ),
      );
    }
    if (!model.hasImages) {
      return const Center(
        child: Text(
          'No images available',
          style: TextStyle(
            color: Colors.white70, // Light gray for no-content text
            fontSize: 16,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(context, 'ATM Images', model.atmImages),
          _buildSection(context, 'Bank Images', model.bankImages),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Uint8List> images) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White section title
            ),
          ),
          const SizedBox(height: 10),
          if (images.isEmpty)
            const Text(
              'No images available',
              style: TextStyle(
                color: Colors.grey, // Gray for empty state
                fontSize: 14,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900], // Dark gray card background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Rounded image corners
                    child: Image.memory(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading image',
                            style: TextStyle(
                              color: Colors.white70, // Light gray error text
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}