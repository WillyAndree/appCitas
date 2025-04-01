import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterAppointmentScreen extends StatefulWidget {
  @override
  _RegisterAppointmentScreenState createState() => _RegisterAppointmentScreenState();
}

class _RegisterAppointmentScreenState extends State<RegisterAppointmentScreen> {
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedTreatment;
  String? selectedWorker;

  final List<String> treatments = ["Limpieza profunda", "Tratamiento para hongos", "Extracción de callosidades"];
  final List<String> workers = ["Dr. Pérez", "Dra. Gómez", "Dr. Ramírez"];
  final List<String> availableTimes = ["09:00 AM", "10:00 AM", "11:00 AM", "02:00 PM", "03:00 PM", "04:00 PM"];
  final List<String> occupiedTimes = ["10:00 AM", "03:00 PM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
          foregroundColor: Colors.white,
          title: Text("Registrar Cita", style: TextStyle(color: Colors.white),)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre del Paciente"),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(selectedDate == null ? "Seleccionar Fecha" : DateFormat('dd/MM/yyyy').format(selectedDate!)),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            Wrap(
              spacing: 10,
              children: availableTimes.map((time) {
                bool isOccupied = occupiedTimes.contains(time);
                return ChoiceChip(
                  label: Text(time),
                  selected: selectedTime == time,
                  onSelected: isOccupied ? null : (selected) {
                    setState(() {
                      selectedTime = selected ? time : null;
                    });
                  },
                  selectedColor: Colors.blue,
                  disabledColor: Colors.grey,
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              value: selectedTreatment,
              hint: Text("Seleccionar Tratamiento"),
              items: treatments.map((treatment) {
                return DropdownMenuItem(
                  value: treatment,
                  child: Text(treatment),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTreatment = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedWorker,
              hint: Text("Seleccionar Trabajador"),
              items: workers.map((worker) {
                return DropdownMenuItem(
                  value: worker,
                  child: Text(worker),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWorker = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Guardar Cita", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
