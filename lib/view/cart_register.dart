
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prycitas/constants.dart';

class CartRegister extends StatefulWidget{
  List? productos;

   CartRegister({super.key, this.productos});
  @override
  _CartRegisterScreenState createState() => _CartRegisterScreenState();

}
class _CartRegisterScreenState extends State<CartRegister>{

  String codigo_cliente ="0";
  String dni_seleccionado ="";
  String cliente_seleccionado ="";
  Future<String> fetchClientes(String dni) async {
    try {
      final response = await http.post(Uri.parse("$url_base/cliente.listar.datos.dni.php"), body: {
        "dni":dni
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var clientesJson = rptaJson["datos"] ?? [];
        if ( clientesJson.isEmpty) {
          setState((){
            codigo_cliente = "0";
          });
            String rpta = await fetchClienteReniec(dni);
            return rpta;

        }else{
          setState((){
            codigo_cliente = clientesJson[0]["codigo"];
            dni_seleccionado = clientesJson[0]["nro_documento_identidad"];
            cliente_seleccionado = clientesJson[0]["nombres"];
          });
            return clientesJson[0]["nombres"];
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener cliente.')),
        );
        return "";
        // return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return "";
      // return [];
    }
  }

  Future<String> fetchClienteReniec(String dni) async {
    try {
      final response = await http.post(Uri.parse("$url_base/consulta_reniecc.php"), body: {
        "dni":dni
      });

      if (response.statusCode == 200) {
        var rptaJson = json.decode(response.body);
        //var clientesJson = rptaJson["datos"] ?? [];
        if ( rptaJson.isEmpty || rptaJson[1] == null) {
          setState((){
            codigo_cliente = "0";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró cliente. Revise el DNI')),
          );
          return "";
        }else{
          setState((){
            codigo_cliente = "0";
            dni_seleccionado = dni;
            cliente_seleccionado = rptaJson[1]+rptaJson[2]+rptaJson[3];
          });
            return rptaJson[1]+rptaJson[2]+rptaJson[3];
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener cliente.')),
        );
        return "";
        // return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
       return "";
    }
  }

  double calcularTotal(List lista) {
    return lista.fold(
        0,
            (suma, item) =>
        suma + (int.parse(item['cantidad']) * (double.parse(item['precio']))));
  }

  Future<void> registerVentas(String codtipopago, String total, String codtipodoc) async {
    DateTime now = DateTime.now();
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
              Text('Registrando venta...'),
            ],
          ),
        );
      },
    );
    try {

      final response = await http.post(Uri.parse("$url_base/venta.agregar.php"), body: {
        "txtfecha":DateFormat('yyyy-MM-dd').format(now), "txtserie":"001","txtdocumento":"1", "txtsucursal": "3", "txtusuario":idusuario_capturado,
        "cbotipodoc":codtipodoc, "cbotipoventa":"Contado", "txtcodigocliente":codigo_cliente, "txtdni":dni_seleccionado, "txtnombres":cliente_seleccionado, "txtdireccion":"-", "txtletras":"-",
        "cbotventa": "E","codtipopago":codtipopago,"product": widget.productos!.map((e) => e["idproducto"]).join(","),
        "medida": widget.productos!.map((e) => e["medida"]).join(","),
        "sucursal": widget.productos!.map((e) => e["sucursal"]).join(","),
        "cantidad": widget.productos!.map((e) => e["cantidad"]).join(","),
        "precio": widget.productos!.map((e) => e["precio"]).join(","),
        "subtotal": widget.productos!.map((e) => e["subtotal"]).join(","),
        "ganancia": widget.productos!.map((e) => e["ganancia"]).join(","),
        "detalle": widget.productos!.map((e) => e["detalle"]).join(",")
      });

      if (response.statusCode == 200) {
        var rptaJson = json.decode(response.body);
        await atenderVentas(rptaJson["datos"], codtipodoc,"3",codigo_cliente,cliente_seleccionado, "-",dni_seleccionado, codtipopago, DateFormat('yyyy-MM-dd').format(now), total);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada correctamente.')),
        );
        Navigator.pop(context,"true");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar venta.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),

      );
      // return [];
    }
    Navigator.pop(context);
  }

  Future<void> atenderVentas(String nro_venta,String tipo,String sucursal,String codigo_cliente, String nombres, String direccion,String dni, String cod_tipopago, String fecha, String total) async {

    try {

      final response = await http.post(Uri.parse("$url_base/venta.atender.php"), body: {
        "nro_venta":nro_venta, "tipo":tipo, "sucursal":sucursal, "codigo":codigo_cliente, "nombres":nombres, "direccion":direccion, "dni":dni, "cod_tipopago":cod_tipopago, "fecha":fecha, "total":total
      });

      if (response.statusCode == 200) {
        // var rptaJson = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago registrada correctamente.')),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar pago.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),

      );
      // return [];
    }

  }


  Future<void> mostrarTipoPago(BuildContext context, String total_venta){
    return showDialog(
      context: context,
      builder: (context) {
        String selectedPaymentMethod = "Efectivo";
        String selectedDocMethod = "Boleta Simple";
        TextEditingController amountController = TextEditingController();
        TextEditingController clientController = TextEditingController();
        String cod_tipodoc = "5";
        String cod_tipopago = "1";
        TextEditingController dniController = TextEditingController();
        amountController.text =  total_venta;
        return AlertDialog(
          title: Text("Registrar Venta"),
          content: SingleChildScrollView(
              child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        onChanged: (value) {
                          selectedPaymentMethod = value!;
                          if(value == "Efectivo"){
                            cod_tipopago = "1";
                          }else if(value == "Tarjeta"){
                            cod_tipopago = "2";
                          }else if(value == "YAPE"){
                            cod_tipopago = "3";
                          }else if(value == "Transferencia"){
                            cod_tipopago = "4";
                          }else if(value == "PLIM"){
                            cod_tipopago = "5";
                          }
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
                              decoration: InputDecoration(labelText: "Total"),
                              onChanged: (val){

                              },
                            ),),

                        ],),),


                      DropdownButtonFormField<String>(
                        value: selectedDocMethod,
                        onChanged: (value) {
                          selectedDocMethod = value!;
                          if(value == "Boleta Simple"){
                            cod_tipodoc = "5";
                          }else{
                            cod_tipodoc = "2";
                          }
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
                        onChanged: (val) async{
                          if(val.length == 8){
                            dni_seleccionado = val;
                            String rpta = await fetchClientes(val);
                            clientController.text = rpta;
                          }

                        },
                      ),
                      TextField(
                        controller: clientController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: "Cliente"),
                        onChanged: (val){
                          setState(() {
                            cliente_seleccionado = val;
                          });
                        },
                      ),
                    ],
                  ))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () async{
                await registerVentas(cod_tipopago, total_venta, cod_tipodoc);
                Navigator.pop(context,"true");
              },
              child: Text("Confirmar", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("Carrito de compras"),),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height*0.9,
      child: widget.productos!.isEmpty
          ? const Center(child: Text("No hay productos seleccionados."))
          : Column( children: [
            Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height*0.75,
                child: ListView.builder(
        itemCount: widget.productos!.length,
        itemBuilder: (context, index) {
          final producto = widget.productos![index];
          return ListTile(
            title: Text(producto["nombres"]),
            subtitle: Text(
                "Cantidad: ${producto["cantidad"]}  -  Precio: S/. ${producto["precio"]}"),
          );
        },
      )),
      Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
          ElevatedButton(
            onPressed: () {
              mostrarTipoPago(context,calcularTotal(widget.productos!).toString());
              //Navigator.pop(context); // Retorna la lista
            },
            child: const Text("Realizar venta"),
          ),
        ],),
      )
    ]),
    ));
  }

}



