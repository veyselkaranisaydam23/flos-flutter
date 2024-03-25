import 'package:flutter/material.dart';

class ShowDialog {
  static void showResponseDialog(BuildContext context, int statusCode, String message, dynamic clientErrors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Status Code: $statusCode\nMessage: $message'),
            backgroundColor: statusCode == 200 || statusCode == 201 ? Colors.green : Colors.red,
          ),
        );

        Future.delayed(Duration(seconds: 3), () {
          _scaffoldKey.currentState?.hideCurrentSnackBar();
        });

        return AlertDialog(
          title: Text('Status Code: $statusCode'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Message: $message'),
              SizedBox(height: 8.0),
              if (clientErrors != null && clientErrors is List)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Client Errors:'),
                    for (var error in clientErrors)
                      if (error is Map<String, dynamic>)
                        Text('- ${error['message']} (Code: ${error['code']})'),
                  ],
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: statusCode == 200 || statusCode == 201
                  ? Icon(Icons.check, color: Colors.green)
                  : Icon(Icons.close, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
