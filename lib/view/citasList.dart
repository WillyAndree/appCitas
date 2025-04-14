import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';
import 'package:prycitas/constants.dart';
import 'package:prycitas/view/citas_register.dart';



class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final List<Appointment> appointments = [/*
    Appointment("Juan Pérez", DateTime.now().add(Duration(minutes: 15)), "Limpieza profunda", "Dr. Pérez"),
    Appointment("Ana López", DateTime.now().add(Duration(hours: 1)), "Tratamiento para hongos", "Dra. Gómez"),
    Appointment("Carlos Sánchez", DateTime.now().add(Duration(hours: 2)), "Extracción de callosidades", "Dr. Ramírez"),*/
  ];
  String selectedDateFilter = "Día";
  String? selectedClient;
  String? selectedWorker;
  DateTime? selectedDate;
  String searchQuery = "";

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    if (selectedDateFilter == "Día") {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
      }
    } else if (selectedDateFilter == "Mes") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int currentYear = DateTime.now().year;
          int currentMonth = DateTime.now().month;

          return AlertDialog(
            title: Text("Selecciona un mes"),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 12, // Solo 12 meses
                      itemBuilder: (context, index) {
                        int month = index + 1; // Mes en el rango 1-12
                        return ListTile(
                          title: Text(
                            DateFormat('MMMM', 'es_ES').format(DateTime(currentYear, month)),
                          ),
                          onTap: () {
                            setState(() {
                              selectedDate = DateTime(currentYear, month);
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (selectedDateFilter == "Año") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedYear = DateTime.now().year;
          return AlertDialog(
            title: Text("Selecciona un año"),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Permite que el diálogo solo ocupe el espacio necesario
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 50,
                      itemBuilder: (context, index) {
                        int year = DateTime.now().year - index;
                        return ListTile(
                          title: Text(year.toString()),
                          onTap: () {
                            setState(() {
                              selectedDate = DateTime(year);
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    await fetchCitas(selectedDate!.day.toString(),selectedDate!.month.toString(),selectedDate!.year.toString() );
  }

  Future<void> fetchCitas( String dia, String mes, String anio) async {


    //List citas = [];

    try {
      final response = await http.post(Uri.parse("$url_base/citas.listar.php"),body:{
        "dia":dia, "mes":mes, "anio":anio
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var citasJson = rptaJson["datos"] ?? [];
        if ( citasJson.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron citas.')),
          );
          return;
        }
        setState(() {
          appointments.add(citasJson);
        });

        //return appointments;
      } else {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener citas.')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: Colors.white,
          backgroundColor: Colors.blue, title: Text("Citas Programadas", style: TextStyle(color: Colors.white),)),
      body: Column(children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: selectedDateFilter,
                items: ["Día", "Mes", "Año"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedDateFilter = newValue!;
                    selectedDate = null;
                  });
                },
              ),
              SizedBox(width: 15,),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(selectedDate == null
                    ? "Seleccionar ${selectedDateFilter.toLowerCase()}"
                    : DateFormat.yMMMd().format(selectedDate!), style: TextStyle(color: Colors.blue),),
              ),


            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(8.0),
        child: TextField(
            decoration: const InputDecoration(
              labelText: "Buscar cliente o trabajador",
              labelStyle: TextStyle( color: Colors.blue,),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              enabledBorder:  OutlineInputBorder(
                borderSide:  BorderSide(color: Colors.grey, width: 0.0),
              ),
             focusedBorder:  OutlineInputBorder(
              borderSide:  BorderSide(color: Colors.grey, width: 0.0),
                ),
            ),

            onChanged: (value) async{
              DateTime now = DateTime.now();
              setState(() {
                searchQuery = value;

              });
              if( selectedDate == null){
                print("dia: ${now.day.toString()}, mes: ${now.month.toString()}, anio: ${now.year.toString()}, cliente: $value, trabajador: $value ");


              }else{
                print("dia: ${selectedDate!.day.toString()}, mes: ${selectedDate!.month.toString()}, anio: ${selectedDate!.year.toString()}, cliente: $value, trabajador: $value ");

              }
             // await fetchCitas(selectedDate!.day.toString(),selectedDate!.month.toString(),selectedDate!.year.toString(),value,value );
            },
          ),),
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height*0.7,
          child: ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return AppointmentCard(appointment: appointments[index]);
            },
          ),
        )

      ],),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterAppointmentScreen()),
          );
        },
        child: Icon(Icons.note_add, color: Colors.white),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          color: Colors.blue.shade600,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  DateFormat('dd/MM/yyyy hh:mm a').format(appointment.dateTime),
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  appointment.doctor,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        back: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          color: Colors.blue.shade800,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Detalles de la Cita",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text("Tratamiento: ${appointment.treatment}", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String selectedPaymentMethod = "Efectivo";
                        String selectedDocMethod = "Boleta Simple";
                        TextEditingController amountController = TextEditingController();
                        TextEditingController clientController = TextEditingController();
                        TextEditingController dniController = TextEditingController();
                        return AlertDialog(
                          title: Text("Cerrar Cita"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: "Precio"),
                              ),
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
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancelar"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Lógica para guardar el pago
                                Navigator.pop(context);
                              },
                              child: Text("Confirmar"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Cerrar Cita", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class Appointment {
  final String clientName;
  final DateTime dateTime;
  final String treatment;
  final String doctor;

  Appointment(this.clientName, this.dateTime, this.treatment, this.doctor);
}

