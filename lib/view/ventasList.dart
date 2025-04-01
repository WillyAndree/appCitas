import 'package:flutter/material.dart';

class SalesListScreen extends StatefulWidget {
  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final List<Map<String, dynamic>> sales = [
    {
      "total": 150.00,
      "cliente": "Juan Pérez",
      "tipoDocumento": "Boleta",
      "numero": "B001-000123",
      "productos": [
        {"nombre": "Crema para pies", "cantidad": 2, "precio":120},
        {"nombre": "Lima eléctrica", "cantidad": 1, "precio":30}
      ],
      "metodoPago": "Efectivo"
    },
    {
      "total": 230.00,
      "cliente": "María López",
      "tipoDocumento": "Boleta",
      "numero": "B001-000124",
      "productos": [
        {"nombre": "Exfoliante", "cantidad": 3, "precio": 230}
      ],
      "metodoPago": "Tarjeta"
    }
  ];

  String searchQuery = "";
  DateTime? selectedDate;

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
