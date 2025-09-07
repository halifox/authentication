import 'package:auth/top_bar.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({this.state = 0, this.title = "", this.message = "", this.falseButtonVisible = false, super.key});

  final int state;
  final String title;
  final String message;
  final bool falseButtonVisible;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(context, ''),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            switch (state) {
              0 => Icon(Icons.error, size: 80, color: Colors.red),
              1 => Icon(Icons.check_circle, size: 80, color: Colors.green),
              int() => throw UnimplementedError(),
            },
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            Spacer(flex: 2),
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Container(
                width: double.infinity,
                height: 56,
                alignment: Alignment.center,
                child: Text("确定", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: falseButtonVisible,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  alignment: Alignment.center,
                  child: Text("取消", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Visibility(visible: falseButtonVisible, child: const SizedBox(height: 8)),
          ],
        ),
      ),
    );
  }
}
