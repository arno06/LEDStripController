import 'package:flutter/material.dart';
import './widgets/ColorPickerInput.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

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

  List<Mode> modes = [];

  final String storage = 'https://api.arnaud-nicolas.fr/storage/ledstrip.setup';

  final storage_header = {
    'id_client':'arno',
    'secret_client':'jwhqlbHV88DkCRGIJ4Hi8zrh7LPMeMRo'
  };

  dynamic setup = null;

  @override
  void initState() {
    super.initState();
    loadStatus();
    modes = [RotationMode(), SequenceMode(), PulseMode(), SpecialsMode()];
  }

  loadStatus() async{
    final response = await http.get(storage);
    if(response.statusCode != 200){
      print("Not available");
      return;
    }
    setState((){
      setup = jsonDecode(response.body);
    });
  }

  saveMode(Map data) async{
    final val = {"date":DateTime.now().toString(), "mode":data};
    await http.post(storage, headers:storage_header, body:{
      "value_storage":jsonEncode(val),
      "type_storage":"application/json"
    });
    loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    List<ExpansionPanel> panels = [];

    Widget currentMode = Text('...');

    Widget floatingButton;

    if(setup != null && setup['mode']['name'] == 'off'){
      currentMode = Icon(Icons.close);
    }else{
      floatingButton = FloatingActionButton(
        onPressed: (){
          saveMode({"name": "off"});
        },
        child: Icon(Icons.close),
      );
    }

    for(var i = 0; i<modes.length; i++){
      Mode mode = modes[i];
      mode.ref = this;
      if (setup != null && mode.name == setup['mode']['name']){
        currentMode = Icon(mode.icon);
        mode.isExpanded = true;
      }
      panels.add(
        ExpansionPanel(
          headerBuilder:(BuildContext context, bool isExpanded){
            return ListTile(title:Text(mode.title), leading: Icon(mode.icon),);
          },
          body:mode.buildBody(),
          isExpanded: mode.isExpanded
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Container(
            padding:EdgeInsets.only(right:10.0),
            child:currentMode
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded){
              setState(() {
                for(var i = 0; i<modes.length; i++){
                  modes[i].isExpanded = i == panelIndex?!isExpanded:false;
                }
              });
            },
            children:panels
          ),
        ),
      ),
      floatingActionButton: floatingButton, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class Mode
{
  final String title;

  final String name;

  _MyHomePageState ref;

  bool isExpanded = false;

  IconData icon;

  Mode(this.title, this.name, this.icon);

  Widget buildBody(){
    return Text('empty');
  }
}

class RotationMode extends Mode
{
  RotationMode():super('Rotation', 'color_rotation', Icons.all_inclusive_rounded);

  double speed = 6.0;

  int direction = 1;

  @override
  Widget buildBody() {
    return Container(
      padding: EdgeInsets.only(left:25.0,right:25.0),
      child: Column(
        children: [
          Row(
            children: [
              Text('Direction'),
              Spacer(),
              IconButton(icon: Icon(direction==1?Icons.arrow_forward_ios_sharp:Icons.arrow_back_ios), onPressed: (){
                direction = direction==1?-1:1;
                ref.setState(() {

                });
              })
            ],
          ),
          Row(
            children: [
              Text('Vitesse'),
              Spacer(),
              Slider(
                onChanged: (double val){
                  this.speed = val.round().toDouble();
                  this.ref.setState(() {

                  });
                },
                value:this.speed,
                min:1.0,
                max:10.0,
                divisions: 10,
              ),
              Text(this.speed.toString()),
            ],
          ),
          Row(
            children: [
              Spacer(),
              IconButton(icon: Icon(Icons.cloud_upload), onPressed: (){
                ref.saveMode({
                  "name":this.name,
                  "params":{
                    "speed":this.speed,
                    "direction":this.direction
                  }
                });
              }),
            ],
          ),
        ],
      ),
    );
  }


}

class SequenceMode extends Mode
{
  SequenceMode():super('Séquence', 'color_alternation',Icons.hdr_weak);
}

class PulseMode extends Mode
{
  PulseMode():super('Pulse', 'color_pulse', Icons.blur_on);
}

class SpecialsMode extends Mode
{
  SpecialsMode():super('Speciaux', 'specials', Icons.star);
}