import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  final List<String> texts;

  AnimatedText(this.texts);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _animation;
  late final List<String> _texts;
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _texts = widget.texts;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation =
        IntTween(begin: 0, end: _texts.length - 1).animate(_controller);

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.reverse();
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _texts.length;
        });
      } else {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _texts[_currentTextIndex],
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
