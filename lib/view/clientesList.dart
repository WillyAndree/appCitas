import 'package:flutter/material.dart';

import 'clientesadd.dart';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final List<String> clients = ["Juan Pérez", "Ana López", "Carlos Sánchez"];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
          title: Text("Listado de Clientes")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Buscar Cliente",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                labelStyle: TextStyle( color: Colors.blue,),
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 0.0),

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
                  .where((client) => client.toLowerCase().contains(searchQuery))
                  .map((client) => ListTile(title: Text(client)))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
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

