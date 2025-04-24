import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prycitas/constants.dart';

class SalesListScreen extends StatefulWidget {
  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {


  List<Map<String, dynamic>> sales = [];

  String searchQuery = "";
  DateTime? selectedDate;

  Future<void> fetchVentas(String nombres,String fecha, String sucursal) async {
    try {
      final response = await http.post(Uri.parse("$url_base/venta.listar.php"), body: {
        "nombres":nombres,"fecha":fecha, "sucursal":sucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var sellJson = rptaJson["datos"] ?? [];
        if ( sellJson.isEmpty) {
          setState((){
            sales.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron ventas.')),
          );
          return;
        }else{
         /* setState((){
            sales.clear();
          });*/


          for(int i = 0; i <sellJson.length; i++){
            setState(() {
              sales.add( {
                "total": double.parse(sellJson[i]["total"]),
                "cliente": sellJson[i]["cliente"],
                "tipoDocumento": sellJson[i]["tipo"],
                "numero": sellJson[i]["nro_documento"],
                "productos": [
                  {"nombre": "Crema para pies", "cantidad": 2, "precio":120},
                  {"nombre": "Lima eléctrica", "cantidad": 1, "precio":30}
                ],
                "metodoPago": sellJson[i]["metodoPago"]
              });
            });
          }
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ventas.')),
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

    WidgetsBinding.instance.addPostFrameCallback((_){
      DateTime actual = DateTime.now();
      fetchVentas("","${actual.year}-${actual.month}-${actual.day}","3");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text("Ventas del Día")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Buscar cliente",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                      String fecha_seleccionada = DateTime.parse(
                          "${selectedDate!.year.toString().padLeft(4, '0')}-"
                              "${selectedDate!.month.toString().padLeft(2, '0')}-"
                              "${selectedDate!.day.toString().padLeft(2, '0')}"
                      ).toString();
                      print(fecha_seleccionada.substring(0,10));
                      fetchVentas("",fecha_seleccionada.substring(0,10),"3");

                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                var sale = sales[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Total: S/ ${sale["total"].toStringAsFixed(2)}"),
                    subtitle: Text("Cliente: ${sale["cliente"]}\n${sale["tipoDocumento"]}: ${sale["numero"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            // Acción para anular la venta
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.print, color: Colors.blue),
                          onPressed: () {
                            // Acción para imprimir la venta
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Detalle de Venta"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Método de Pago: ${sale["metodoPago"]}"),
                              SizedBox(height: 10),
                              Text("Productos:"),
                              ...sale["productos"].map<Widget>((p) => Text("- ${p["nombre"]} - cant.:${p["cantidad"]} - prec.:${p["precio"]}"))
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cerrar", style: TextStyle(color: Colors.blue)),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
