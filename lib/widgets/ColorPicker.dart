import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:image/image.dart' as Img;
import '../utils/Color.dart' as cUtils;

class ColorPicker extends StatefulWidget
{
  double width;
  double height;
  Color color;
  void Function(Color) onColorChanged;

  ColorPickerPainter pickerPainter;

  ColorPicker({this.width, this.height, this.color, this.onColorChanged});

  @override
  _ColorPickerState createState() {
    return _ColorPickerState(width:this.width, height:this.height, wheelColor:this.color, onColorChanged:this.onColorChanged);
  }
}

class ColorWheelPainter extends CustomPainter
{
  Offset position;

  ColorWheelPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) async {
    paintPicker(canvas, size);
    Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black;
    double x = max(this.position.dx, 0.0);
    x = min(x, size.width);
    canvas.drawRect(Rect.fromCenter(center:Offset(x, size.height/2), width:15.0, height:(size.height).toDouble()), p);
    final rec = new ui.PictureRecorder();
    final c = Canvas(rec, Rect.fromPoints(Offset(0,0), Offset(size.width, size.height)));
    paintPicker(c, size);
    final pic = rec.endRecording();
    final img = await pic.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await img.toByteData();
    _ColorPickerState.wheelPainterImg = Img.Image.fromBytes(size.width.toInt(), size.height.toInt(), bytes.buffer.asInt8List());
  }

  void paintPicker(Canvas canvas, Size size){
    var paint = new Paint()
      ..shader = ui.Gradient.linear(Offset(0.0, 0.0), Offset(size.width, 0.0), [
        Colors.redAccent,
        Colors.pinkAccent,
        Colors.blueAccent,
        Colors.lightBlueAccent,
        Colors.lightGreenAccent,
        Colors.yellow,
        Colors.orangeAccent,
        Colors.redAccent,
      ], [.125, .25, .375, .5, .625, .75, .875, 1.0]);
    canvas.drawRect(Rect.fromPoints(Offset(0.0,0.0), Offset(size.width, size.height)), paint);
  }

  @override
  bool shouldRepaint(ColorWheelPainter oldDelegate) {
    return oldDelegate.position.dx != this.position.dx
        || oldDelegate.position.dy != this.position.dy;
  }
}

class ColorPickerPainter extends CustomPainter
{
  Color color;

  Offset position;

  @override
  bool shouldRepaint(ColorPickerPainter oldDelegate) {
    return oldDelegate.color.red != this.color.red
        || oldDelegate.color.green != this.color.green
        || oldDelegate.color.blue != this.color.blue
        || oldDelegate.position.dx != this.position.dx
        || oldDelegate.position.dy != this.position.dy;
  }

  @override
  void paint(Canvas canvas, Size size) async {
    paintPicker(canvas, size);
    Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black;
    double x = max(0, this.position.dx);
    x = min (x, size.width);
    double y = max(0, this.position.dy);
    y = min(y, size.height);
    canvas.drawCircle(Offset(x, y), 15, p);
    final rec = new ui.PictureRecorder();
    final c = Canvas(rec, Rect.fromPoints(Offset(0,0), Offset(size.width, size.height)));
    paintPicker(c, size);
    final pic = rec.endRecording();
    final img = await pic.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await img.toByteData();
    _ColorPickerState.pickerPainterImg = Img.Image.fromBytes(size.width.toInt(), size.height.toInt(), bytes.buffer.asInt8List());
  }

  void paintPicker(Canvas canvas, Size size){
    var paint = new Paint()
      ..style = PaintingStyle.fill
      ..color = this.color;
    canvas.drawRect(Rect.fromPoints(Offset(0.0, 0.0), Offset(size.width, size.height)), paint);

    paint = new Paint()
      ..shader = ui.Gradient.linear(Offset(0, 0), Offset(size.width, 0.0), [
        Color.fromRGBO(255, 255, 255, 1.0),
        Color.fromRGBO(255, 255, 255, 0.0)
      ]);
    canvas.drawRect(Rect.fromPoints(Offset(0.0, 0.0), Offset(size.width, size.height)), paint);

    paint = new Paint()
      ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0.0, size.height), [
        Color.fromRGBO(0, 0, 0, 0.0),
        Color.fromRGBO(0, 0, 0, 1.0)
      ]);
    canvas.drawRect(Rect.fromPoints(Offset(0.0, 0.0), Offset(size.width, size.height)), paint);
  }

  ColorPickerPainter(this.color, this.position);
}


class _ColorPickerState extends State<ColorPicker>
{
  double width;
  double height;
  Color wheelColor;
  void Function(Color) onColorChanged;
  Color pickerColor = Colors.white;
  Offset wheelPosition = Offset(0.0, 0.0);
  Offset pickerPosition = Offset(0.0, 0.0);

  static Img.Image wheelPainterImg;
  static Img.Image pickerPainterImg;

  _ColorPickerState({this.width, this.height, this.wheelColor, this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            width:this.width,
            height:10,
            color:this.pickerColor
        ),
        Container(
            width:this.width,
            height:this.height,
            child: new Listener(
              onPointerMove: this.pickerPointerEventHandler,
              onPointerDown: this.pickerPointerEventHandler,
              onPointerUp: this.pickerPointerEventHandler,
              child: CustomPaint(
                painter: ColorPickerPainter(this.wheelColor, this.pickerPosition),
              ),
            )
        ),
        Container(
            width:this.width,
            height:50.0,
            child:new Listener(
              onPointerMove: this.wheelPointerEventHandler,
              onPointerDown: this.wheelPointerEventHandler,
              onPointerUp: this.wheelPointerEventHandler,
              child: CustomPaint(
                  painter:ColorWheelPainter(this.wheelPosition)
              ),
            )
        )
      ],
    );
  }

  void pickerPointerEventHandler(PointerEvent e){
    setState((){
      this.pickerPosition = e.localPosition;
      this.getPickerColor();
    });
  }

  void wheelPointerEventHandler(PointerEvent e){
    final c = _ColorPickerState.getColor(_ColorPickerState.wheelPainterImg, e.localPosition.dx, 25.0);
    setState((){
      if(c != null){
        this.wheelColor = c;
      }
      this.wheelPosition = e.localPosition;
      this.getPickerColor();
    });
  }

  void getPickerColor(){
    double x = max(0.0, this.pickerPosition.dx);
    x = min(x, _ColorPickerState.pickerPainterImg.width.toDouble()-1.0);
    double y = max(0.0, this.pickerPosition.dy);
    y = min(y, _ColorPickerState.pickerPainterImg.height.toDouble()-1.0);
    final c = _ColorPickerState.getColor(_ColorPickerState.pickerPainterImg, x, y);
    if( c != null){
      this.pickerColor = c;
      if(this.onColorChanged != null){
        this.onColorChanged(this.pickerColor);
      }
    }
  }

  static Color getColor(Img.Image img, double x, double y){
    if(x < 0 || x >= img.width || y < 0 || y >= img.height){
      return null;
    }
    final c = img.getPixel(x.toInt(), y.toInt());
    return cUtils.fromInt(c);
  }
}