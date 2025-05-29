import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prycitas/constants.dart';

class CashboxScreen extends StatefulWidget {
  @override
  _CashboxScreenState createState() => _CashboxScreenState();
}

class _CashboxScreenState extends State<CashboxScreen> {
   Map<String, double> payments = {};

  Future<void> fetchCaja(String fecha, String sucursal) async {
    try {
      final response = await http.post(Uri.parse("$url_base/caja.montos.listar.php"), body: {
        "fecha":fecha, "sucursal":sucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var paymentJson = rptaJson["datos"] ?? [];
        if ( paymentJson.isEmpty) {
          setState((){
            payments.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron productos.')),
          );
          return;
        }else{
          setState((){
            payments.clear();
          });


          for(int i = 0; i <paymentJson.length; i++){
            setState(() {
              payments = {
                "Caja inicial": double.parse(paymentJson[i]["monto_inicial"]),
                "Efectivo": double.parse(paymentJson[i]["ventas_efectivo"]),
                "Tarjeta": double.parse(paymentJson[i]["ventas_tarjeta"]),
                "Yape": double.parse(paymentJson[i]["credito"]),
                "Plin": double.parse(paymentJson[i]["plim"]),
                "Transferencia": 0.00,
                "Efectivo en caja": double.parse(paymentJson[i]["efectivo_caja"]),
              };
            });
          }
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener productos.')),
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

  final List<Color> colors = [
    Colors.blueGrey,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal
  ];

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      DateTime actual = DateTime.now();
      fetchCaja("${actual.year}-${actual.month}-${actual.day}",idsucursal );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(onPressed: (){

            }, icon: Icon(Icons.card_membership_sharp))
          ],
          title: Text("Caja")),
      body: SingleChildScrollView( child:
      Container(
        width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height *0.9,
          child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Seleccionar Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                  await fetchCaja("${selectedDate.year}-${selectedDate.month}-${selectedDate.day}", "3" );
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top:10, left: 10, right: 10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  String method = payments.keys.elementAt(index);
                  double amount = payments.values.elementAt(index);
                  return Card(
                    color: colors[index % colors.length],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            method,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "S/ ${amount.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          /*ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Arquear Caja", style: TextStyle(color: Colors.white),),
          ),*/
        ],
      ))),
    );
  }
}
