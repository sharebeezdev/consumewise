import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int? _selectedRating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'Provide Feedback',
            style: TextStyle(color: Colors.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'How accurate was the information provided?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  child: Icon(
                    Icons.star,
                    size: 48,
                    color: _selectedRating != null && _selectedRating! > index
                        ? Colors.amber
                        : Colors.grey,
                  ),
                );
              }),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selectedRating != null ? _submitFeedback : null,
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    // Handle feedback submission (e.g., send feedback to server or save locally)
    Navigator.pop(
        context); // Go back to the previous screen after feedback submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you for your feedback!')),
    );
  }
}
