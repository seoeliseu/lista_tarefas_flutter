import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    title: "Lista de tarefas",
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _toDo = new TextEditingController();

  List _doToList = [];
  
  @override
  void initState()  {
    super.initState();

    _readData().then((data){
      setState(() {
        _doToList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    if (_toDo.text != "") {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDo.text;
      _toDo.text = "";
      newToDo["ok"] = false;
      setState(() {
        _doToList.add(newToDo);
        _saveData();
      });
    }
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_doToList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                    controller: _toDo,
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _doToList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_doToList[index]["title"]),
                    value: _doToList[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(
                          _doToList[index]["ok"] ? Icons.check : Icons.error),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _doToList[index]["ok"] = value;
                        _saveData();
                      });
                    },
                  );
                }),
          )
        ],
      ),
    );
  }
}
