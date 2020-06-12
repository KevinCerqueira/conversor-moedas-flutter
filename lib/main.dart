import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=cdca3e51";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          ))));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _cleanAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
  void _resetFields(){
    _cleanAll();
    main();
  }

  void _realChanged(String text){
    if(text.isEmpty){
      _cleanAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsPrecision(5);
    euroController.text = (real/euro).toStringAsPrecision(5);
  }
  void _dolarChanged(String text){
    if(text.isEmpty){
      _cleanAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsPrecision(5);
    euroController.text = (dolar * this.dolar/euro).toStringAsPrecision(5);
  }
  void _euroChanged(String text){
    if(text.isEmpty){
      _cleanAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsPrecision(5);
    dolarController.text = (euro * this.euro/dolar).toStringAsPrecision(5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: Text("Conver\$or de Moeda"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetFields,
          )
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:

            case ConnectionState.waiting:
              return Center(
                  child: Text("Carregando dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center));
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text("Erro ao Carregar Dados :(",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center));
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      Divider(),
                      buildTextField("Real" , "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField("Dolar", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euro", "€ ", euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController moedaController, Function func){
  return TextField(
    controller: moedaController,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: func,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

