import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prycitas/constants.dart';
import 'clientesadd.dart';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final List clients = [];
  String searchQuery = "";

  Future<void> fetchClientes(String cliente) async {
    try {
      final response = await http.post(Uri.parse("$url_base/cliente.listar.nombres.php"), body: {
        "nombres":cliente
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var clientesJson = rptaJson["datos"] ?? [];
        if ( clientesJson.isEmpty) {
          setState((){
            clients.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron clientes.')),
          );
          return;
        }else{
          setState((){
            clients.clear();
          });


          for(int i = 0; i <clientesJson.length; i++){
            setState(() {
              clients.add({
                "codigo":clientesJson[i]["codigo"],
                "nombres":clientesJson[i]["nombres"]
              });
            });
          }
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener clientes.')),
        );
        // return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // return [];
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchClientes("");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
          title: const Text("Listado de Clientes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Buscar Cliente",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                labelStyle: TextStyle( color: Colors.blue,),
                enabledBorder:  OutlineInputBorder(
                  borderSide:  BorderSide(color: Colors.grey, width: 0.0),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderSide:  BorderSide(color: Colors.grey, width: 0.0),

                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: clients
                  .where((client) => client["nombres"].toLowerCase().contains(searchQuery))
                  .map((client) => ListTile(
                title: Text(client["nombres"]),
                //subtitle: Text("Código: ${client["codigo"]}"),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClientScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

