// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart' hide Ink;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

import 'package:smartboard/activity_indicator/activity_indicator.dart';
import 'package:smartboard/custom_widgets/OnlyOnePointerRecognizerWidget.dart';
import 'package:smartboard/services/mathpix_api/mathpix.dart';

class DigitalInkView extends StatefulWidget {
  @override
  State<DigitalInkView> createState() => _DigitalInkViewState();
}

class _DigitalInkViewState extends State<DigitalInkView> {
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  late Map _recognizedText = {};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Digital Ink Recognition')),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (DragStartDetails details) {
                  _ink.strokes.add(Stroke());
                },
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    final RenderObject? object = context.findRenderObject();
                    final localPosition = (object as RenderBox?)?.globalToLocal(details.localPosition);
                    if (localPosition != null) {
                      _points = List.from(_points)
                        ..add(StrokePoint(
                          x: localPosition.dx,
                          y: localPosition.dy,
                          t: DateTime.now().millisecondsSinceEpoch,
                        ));
                    }
                    if (_ink.strokes.isNotEmpty) {
                      _ink.strokes.last.points = _points.toList();
                    }
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  _points.clear();
                  setState(() {});
                },
                child: OnlyOnePointerRecognizerWidget(
                  child: CustomPaint(
                    painter: Signature(ink: _ink),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _recogniseText,
                    child: Text('Read Text'),
                  ),
                  ElevatedButton(
                    onPressed: _clearPad,
                    child: const Text('Clear Pad'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                    padding: EdgeInsets.all(20),
                    color: Colors.red,
                    child: Math.tex(
                        'Recognized Equation: ${_recognizedText['standardFormat']}, answer: ${_recognizedText['solutionLaTex']}',
                        mathStyle: MathStyle.display)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearPad() {
    setState(() {
      _ink.strokes.clear();
      _points.clear();
      _recognizedText = {};
    });
  }

  Future<void> _recogniseText() async {
    // print(_ink.strokes.length);
    // print(_ink.strokes.first.points.first.x);

    double x_minimum = 0.0, x_maximum = 0.0, y_minimum = 0.0, y_maximum = 0.0;

    List x_strokes = [], y_strokes = [];

    _ink.strokes.removeWhere((stroke) => stroke.points.isEmpty);

    for (var stroke in _ink.strokes) {
      List x_points = [], y_points = [];

      for (var point in stroke.points) {
        x_minimum = x_minimum == 0.0
            ? point.x
            : x_minimum > point.x
                ? point.x
                : x_minimum;

        x_maximum = x_maximum == 0.0
            ? point.x
            : x_maximum < point.x
                ? point.x
                : x_maximum;

        y_minimum = y_minimum == 0.0
            ? point.y
            : y_minimum > point.y
                ? point.y
                : y_minimum;

        y_maximum = y_maximum == 0.0
            ? point.y
            : y_maximum < point.y
                ? point.y
                : y_maximum;

        x_points.add(point.x.toInt());
        y_points.add(point.y.toInt());
      }

      x_strokes.add(x_points);
      y_strokes.add(y_points);
    }

    //!  making a box around selected areas   !///
    // print(
    //     'p1 = ($x_minimum, $y_minimum), p2 = ($x_maximum, $y_minimum), p3 = ($x_minimum, $y_maximum), p4 = ($x_maximum, $y_maximum)');

    // ignore: unnecessary_cast
    _recognizedText = await MathPix().processStrokeData(x_strokes, y_strokes) as Map;

    // print(_recognizedText['solution'][0]);

    setState(() {});

    // List<StrokePoint> boxStrokes = [];

    // boxStrokes.add(StrokePoint(x: x_minimum-10, y: y_maximum+10, t: DateTime.now().millisecondsSinceEpoch));
    // boxStrokes.add(StrokePoint(x: x_maximum+10, y: y_maximum+10, t: DateTime.now().millisecondsSinceEpoch));
    // boxStrokes.add(StrokePoint(x: x_maximum+10, y: y_minimum-10, t: DateTime.now().millisecondsSinceEpoch));
    // boxStrokes.add(StrokePoint(x: x_minimum-10, y: y_minimum-10, t: DateTime.now().millisecondsSinceEpoch));
    // boxStrokes.add(StrokePoint(x: x_minimum-10, y: y_maximum+10, t: DateTime.now().millisecondsSinceEpoch));

    // _ink.strokes.add(Stroke());
    // _ink.strokes.last.points = boxStrokes;

    // setState(() {

    // });
  }
}

class Signature extends CustomPainter {
  Ink ink;

  Signature({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (final stroke in ink.strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(
            Offset(p1.x.toDouble(), p1.y.toDouble()), Offset(p2.x.toDouble(), p2.y.toDouble()), paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => true;
}
