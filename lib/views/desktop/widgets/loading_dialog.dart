import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const double size = 150;

    return const AlertDialog(
      content: SizedBox(
        height: size,
        width: size,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 35),
              Text("Searching..."),
            ],
          ),
        ),
      ),
    );
  }
}
