import 'package:flutter/material.dart';


class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Map<String, dynamic>> products = [
    {"name": "Crema Hidratante", "price": 25.0, "stock": 15},
    {"name": "Alcohol en Gel", "price": 10.0, "stock": 30},
    {"name": "Lima de Uñas", "price": 5.0, "stock": 50},
    {"name": "Antiséptico", "price": 18.0, "stock": 20},
    {"name": "Parche Protector", "price": 12.0, "stock": 25},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text("Productos")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                if (!product["name"].toLowerCase().contains(searchQuery)) {
                  return Container();
                }
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(children: [
                    ListTile(
                      title: Text(product["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text("Stock: ${product["stock"]}",style: TextStyle(fontSize: 16),),
                      trailing: Text("S/ ${product["price"].toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                        child:IconButton(onPressed: (){
                          showDialog(
                            context: context,
                            builder: (context) {
                              String selectedPaymentMethod = "Efectivo";
                              String selectedDocMethod = "Boleta Simple";
                              String total = "${product["price"].toStringAsFixed(2)}";
                              TextEditingController amountController = TextEditingController();
                              TextEditingController cantController = TextEditingController();
                              TextEditingController clientController = TextEditingController();
                              TextEditingController dniController = TextEditingController();
                              amountController.text = "${product["price"].toStringAsFixed(2)}";
                              cantController.text = "1.0";
                              return AlertDialog(
                                title: Text("Registrar Venta"),
                                content: SingleChildScrollView(
                                    child: Container(
                                        child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(total, style: TextStyle(fontSize: 16),),
                                    ),
                                    DropdownButtonFormField<String>(
                                      value: selectedPaymentMethod,
                                      onChanged: (value) {
                                        selectedPaymentMethod = value!;
                                      },
                                      items: ["Efectivo", "Tarjeta", "Yape", "Plin", "Transferencia"].map((method) {
                                        return DropdownMenuItem(
                                          value: method,
                                          child: Text(method),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(labelText: "Método de Pago"),
                                    ),
                                    Container(
                                      width: MediaQuery.sizeOf(context).width*0.8,
                                      child:
                                    Row(children: [
                                      Container(
                                        width: MediaQuery.sizeOf(context).width*0.3,
                                        child: TextField(
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(labelText: "Precio"),
                                          onChanged: (val){

                                              if(val.isNotEmpty){
                                                String cantidad = cantController.text;
                                                setState(() {
                                                total = (double.parse(cantidad) * double.parse(val)).toStringAsFixed(2);
                                                });
                                              }


                                          },
                                        ),),
                                      SizedBox(width: 10,),
                                      Container(
                                        width: MediaQuery.sizeOf(context).width*0.3,
                                        child:TextField(
                                        controller: cantController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(labelText: "Cantidad"),
                                          onChanged: (val){

                                            if(val.isNotEmpty){
                                              String precio = amountController.text;
                                              setState(() {
                                              total = (double.parse(precio) * double.parse(val)).toStringAsFixed(2);
                                              });
                                            }
                                          },
                                      ),),

                                    ],),),


                                    DropdownButtonFormField<String>(
                                      value: selectedDocMethod,
                                      onChanged: (value) {
                                        selectedDocMethod = value!;
                                      },
                                      items: ["Boleta Simple", "Boleta"].map((method) {
                                        return DropdownMenuItem(
                                          value: method,
                                          child: Text(method),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(labelText: "Tipo de Documento"),
                                    ),
                                    TextField(
                                      controller: dniController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(labelText: "DNI"),
                                    ),
                                    TextField(
                                      controller: clientController,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(labelText: "Cliente"),
                                    ),
                                  ],
                                ))),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancelar", style: TextStyle(color: Colors.blue)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Lógica para guardar el pago
                                      Navigator.pop(context);
                                    },
                                    child: Text("Confirmar", style: TextStyle(color: Colors.blue)),
                                  ),
                                ],
                              );
                            },
                          );
                    }, icon: Icon(Icons.sell, color: Colors.blue,)) )

                  ],)
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
