import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prycitas/constants.dart';
import 'package:prycitas/view/clientesedit.dart';
import 'package:url_launcher/url_launcher.dart';
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
                "nombres":clientesJson[i]["nombres"],
                "dni":clientesJson[i]["dni"],
                "direccion":clientesJson[i]["direccion"],
                "celular":clientesJson[i]["celular"] ?? "",
                "fecha_nacimiento":clientesJson[i]["fecha_nacimiento"] ?? ""
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

  void _mostrarDialogoOpciones(String codigo, String name, String dni, String direccion, String celular, String nacimiento) async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecciona una opción'),
        content: Text('¿Qué deseas hacer con este cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('eliminar'),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('editar'),
            child: Text('Editar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      print("Opción seleccionada: $resultado");
      // Aquí puedes manejar la lógica según la opción seleccionada
      if (resultado == 'eliminar') {
        await registerCitas(codigo, "", "", "", "", "");
        await fetchClientes("");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cliente eliminado.')));
      } else if (resultado == 'editar') {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditClientScreen(codigo: codigo,name: name, dni: dni, direccion: direccion, celular: celular, nacimiento: nacimiento)),
        );
      }
    }
  }

  Future<void> registerCitas(String codigo,String nombres, String dni, String fecha_nacimiento, String celular,String direccion) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Eliminando cliente...'),
            ],
          ),
        );
      },
    );
    try {
      final response = await http.post(Uri.parse("$url_base/clientes.editar.app.php"), body: {
        "codigo":codigo,"nombres":nombres, "dni":dni, "fecha_nacimiento": fecha_nacimiento, "celular":celular, "direccion":direccion, "tipo": "Eliminar"
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var rptJson = rptaJson["datos"] ?? [];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar cliente.')),
        );
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // return [];
    }
    Navigator.pop(context);
  }

  Future<void> _launchURL(String enlace) async {
    final Uri url = Uri.parse(enlace);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir la URL: $enlace');
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
                title: GestureDetector(
                  onTap: () {
                    print("HOla");
                    _mostrarDialogoOpciones(client["codigo"],client["nombres"], client["dni"], client["direccion"], client["celular"], client["fecha_nacimiento"]);
                  },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 15 , horizontal: 10),
                          child: Text(client["nombres"])),
                      Container(child: IconButton(icon: Icon(Icons.mark_unread_chat_alt_rounded),
                          onPressed:(){
                        String enlace = "https://wa.me/${client["celular"]}?text=Hola";
                        _launchURL(enlace);
                      }))
    ],)),
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

