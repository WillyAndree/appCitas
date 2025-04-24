import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prycitas/constants.dart';
import 'package:prycitas/view/cart_register.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Map<String, dynamic>> products = [];

  String searchQuery = "";
  List products_cart = [];

  Future<void> fetchProducts(String producto) async {
    try {
      final response = await http.post(Uri.parse("$url_base/producto.listar.nombres.php"), body: {
        "nombres":producto
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var productsJson = rptaJson["datos"] ?? [];
        if ( productsJson.isEmpty) {
          setState((){
            products.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron productos.')),
          );
          return;
        }else{
          setState((){
            products.clear();
          });


          for(int i = 0; i <productsJson.length; i++){
            setState(() {
              products.add({
                "codigo":productsJson[i]["codigo"],
                "nombres":productsJson[i]["nombre"],
                "stock":productsJson[i]["stock"],
                "precio":productsJson[i]["precio"],
                "estado":productsJson[i]["estado"]
              });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProducts("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(onPressed: () async{
              final rpta = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartRegister(productos: products_cart,)),
              );
              if(rpta != null){
                setState(() {
                  products_cart.clear();
                });

              }
              //mostrarDialogoProductos(context,products_cart);
            }, icon: Icon(products_cart.isNotEmpty ? Icons.shopping_cart_checkout : Icons.shopping_cart, color: products_cart.isNotEmpty ? Colors.red: Colors.white,))
          ],
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
                if (!product["nombres"].toLowerCase().contains(searchQuery)) {
                  return Container();
                }
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(children: [
                    ListTile(
                      title: Text(product["nombres"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text("Stock: ${product["stock"]}",style: TextStyle(fontSize: 16),),
                      trailing: Text("S/ ${product["precio"]}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                        child:IconButton(
                            onPressed: () async{
                              final respuesta = await _mostrarDialogoAgregarProducto(context, product["precio"]);
                              if (respuesta != null) {
                                setState(() {
                                  products_cart.add({
                                    "idproducto":product["codigo"],
                                    "nombres":product["nombres"],
                                    "cantidad":respuesta["cantidad"],
                                    "precio":respuesta["precio"],
                                    "detalle":respuesta["comentario"],
                                    "medida":"UND",
                                    "sucursal":"3",
                                    "subtotal": (int.parse(respuesta["cantidad"].toString()) * double.parse(respuesta["precio"].toString())).toString(),
                                    "ganancia": "0",
                                  });
                                });

                              } else {
                                print("El usuario canceló.");
                              }

                              print(products_cart.toString());
                          /*showDialog(
                            context: context,
                            builder: (context) {
                              String selectedPaymentMethod = "Efectivo";
                              String selectedDocMethod = "Boleta Simple";
                              String total = "${product["precio"]}";
                              TextEditingController amountController = TextEditingController();
                              TextEditingController cantController = TextEditingController();
                              TextEditingController clientController = TextEditingController();
                              TextEditingController dniController = TextEditingController();
                              amountController.text = "${product["precio"]}";
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
                          );*/
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



Future<Map<String, String>?> _mostrarDialogoAgregarProducto(BuildContext context, String precio) {
  TextEditingController cantidadController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController comentarioController = TextEditingController();

  cantidadController.text = "0";
  precioController.text = precio;

  return showDialog<Map<String, String>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Agregar Producto"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Cantidad"),
              ),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Precio"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: comentarioController,
                maxLines: 2,
                decoration: InputDecoration(labelText: "Comentario"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cancelar, retorna null
            },
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop({
                "cantidad": cantidadController.text,
                "comentario": comentarioController.text,
                "precio": precioController.text,
              }); // Retorna un Map<String, String>
            },
            child: Text("Agregar"),
          ),
        ],
      );
    },
  );
}

