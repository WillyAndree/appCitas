import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashboxScreen extends StatefulWidget {
  @override
  _CashboxScreenState createState() => _CashboxScreenState();
}

class _CashboxScreenState extends State<CashboxScreen> {
  final Map<String, double> payments = {
    "Caja inicial": 100.0,
    "Efectivo": 1500.0,
    "Tarjeta": 1200.0,
    "Yape": 800.0,
    "Plin": 600.0,
    "Transferencia": 950.0,
    "Efectivo en caja": 1600.0,
  };

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
