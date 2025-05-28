import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prycitas/constants.dart';
import 'package:http/http.dart' as http;
import 'package:prycitas/view/clientesList.dart';

class EditClientScreen extends StatefulWidget {

  String name, dni, direccion, celular, nacimiento, codigo;

  EditClientScreen({
    Key? key,
    required this.name,
    required this.dni,
    required this.direccion,
    required this.celular,
    required this.nacimiento,
    required this.codigo
  }) : super(key: key);
  @override
  _EditClientScreenState createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController celController = TextEditingController();
  DateTime? birthDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.name;
    dniController.text = widget.dni;
    addressController.text = widget.direccion;
    celController.text = widget.celular;
    birthDate = widget.nacimiento.isNotEmpty
        ? DateTime.parse(widget.nacimiento)
        : null;
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
              Text('Editando cliente...'),
            ],
          ),
        );
      },
    );
    try {
      final response = await http.post(Uri.parse("$url_base/clientes.editar.app.php"), body: {
        "codigo":codigo,"nombres":nombres, "dni":dni, "fecha_nacimiento": fecha_nacimiento, "celular":celular, "direccion":direccion, "tipo": "Editar"
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var rptJson = rptaJson["datos"] ?? [];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente editado correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al editar cliente.')),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text("Agregar Cliente")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre del Cliente"),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(birthDate == null ? "Seleccionar Fecha de Nacimiento" : DateFormat('dd/MM/yyyy').format(birthDate!)),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    birthDate = pickedDate;
                  });
                }
              },
            ),
            TextField(
              controller: dniController,
              decoration: InputDecoration(labelText: "DNI"),
              keyboardType: TextInputType.number,
              maxLength: 8,
            ),
            TextField(
              controller: celController,
              decoration: InputDecoration(labelText: "Celular (Opcional)"),
              keyboardType: TextInputType.number,
              maxLength: 9,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Dirección (Opcional)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
              onPressed: () async{
                await registerCitas(widget.codigo,nameController.text,  dniController.text, DateFormat("yyyy-MM-dd").format(birthDate!), celController.text, addressController.text);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientListScreen()),
                );
              },
              child: Text("Guardar cliente", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}