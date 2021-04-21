import 'package:flutter/material.dart';
import './ColorPicker.dart';

class ColorPickerInput extends StatefulWidget
{
  final double width;
  final double height;

  ColorPickerInput({this.width, this.height});

  @override
  State createState() => _ColorPickerInputState(width:this.width, height:this.height);
}

class _ColorPickerInputState extends State<ColorPickerInput>
{
  Color color = Color.fromRGBO(255, 0, 0, 1.0);

  double width;

  double height;

  _ColorPickerInputState({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (PointerEvent event){
        showDialog(
            context: this.context,
            builder:(BuildContext ctx){
              return AlertDialog(
                title: Text('Sélectionner une couleur'),
                content: ColorPicker(
                    width:300,
                    height:300,
                    color:Color.fromRGBO(this.color.red, this.color.green, this.color.blue, 1.0),
                    onColorChanged:(Color color){
                      this.color = color;
                    }
                ),
                actions: [
                  Container(
                    height:60,
                    child: FlatButton(
                      child: Text('Valider'),
                      onPressed: (){
                        setState((){
                          this.color = this.color;
                        });
                        Navigator.pop(this.context);
                      },
                    ),
                  )
                ],
              );
            });
      },
      child: Container(
          width:this.width,
          height:this.height,
          color:this.color
      ),
    );
  }
}