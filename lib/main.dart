import 'package:flutter/material.dart';
import './widgets/ColorPicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Strip controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'LED Strip controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Color color = Color.fromRGBO(255, 0, 0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Listener(
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
              width:100,
              height:100,
              color:this.color
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
