import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddClientScreen extends StatefulWidget {
  @override
  _AddClientScreenState createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController celController = TextEditingController();
  DateTime? birthDate;

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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Guardar cliente", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}