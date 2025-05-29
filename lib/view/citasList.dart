import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';
import 'package:prycitas/constants.dart';
import 'package:prycitas/model/citas/appoiments.dart';
import 'package:prycitas/view/citas_register.dart';
import 'package:prycitas/view/historias_clinicas.dart';



class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final List<Appointment> appointments = [];
  String selectedDateFilter = "Día";
  String? selectedClient;
  String? selectedWorker;
  DateTime? selectedDate;
  String searchQuery = "";
  List filteredAppointments = [];




  Future<void> _selectDate(BuildContext context) async {
    DateTime actual = DateTime.now();
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
    if(selectedDate == null){
      await fetchCitas(actual.day.toString(),actual.month.toString(),actual.year.toString() );
    }else{
      await fetchCitas(selectedDate!.day.toString(),selectedDate!.month.toString(),selectedDate!.year.toString() );
    }

  }

  Future<void> fetchCitas( String dia, String mes, String anio) async {
    DateTime now = DateTime.now();
    try {
      final response = await http.post(Uri.parse("$url_base/citas.listar.php"),body:{
        "dia":dia, "mes":mes, "anio":anio, "idsucursal":idsucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var citasJson = rptaJson["datos"] ?? [];
        if ( citasJson.isEmpty) {
          setState((){
            appointments.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron citas.')),
          );
          return;
        }else{
          setState((){
            appointments.clear();
          });


          for(int i = 0; i <citasJson.length; i++){

            setState(() {
              final now = DateTime.now();
              final currentTime = DateTime.parse(
                  "${now.year.toString().padLeft(4, '0')}-"
                      "${now.month.toString().padLeft(2, '0')}-"
                      "${now.day.toString().padLeft(2, '0')} "
                      "${now.hour.toString().padLeft(2, '0')}:"
                      "${now.minute.toString().padLeft(2, '0')}:00"
              );

              final citaTime = DateTime.parse(
                  "${citasJson[i]["fecha"]} "
                      "${citasJson[i]["hora"].toString().substring(0, 5)}:00"
              );


              appointments.add(Appointment(citasJson[i]["idcita"],citasJson[i]["cliente"], citasJson[i]["fecha"]+" "+citasJson[i]["hora"], citasJson[i]["servicio"], citasJson[i]["trabajador"], citasJson[i]["codigo_producto"], citasJson[i]["precio"], citasJson[i]["estado"], citasJson[i]["antecedentes"]??"", citasJson[i]["tratamientos"]??"", citasJson[i]["diagnosticos"]??""));

            });
          }
          _filterAppointments;
        }

      } else {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener citas.')),
        );
       // return [];
      }
    } catch (e) {
      //Navigator.of(context).pop();
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
    WidgetsBinding.instance.addPostFrameCallback((_){
      DateTime actual = DateTime.now();
      fetchCitas(actual.day.toString(),actual.month.toString(),actual.year.toString() );
    });
    filteredAppointments = appointments;
  }

  void _filterAppointments(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredAppointments = appointments.where((appointment) {
        final nombre = appointment.clientName.toString().toLowerCase() ?? '';
        final trabajador = appointment.doctor.toString().toLowerCase() ?? '';
        return nombre.contains(searchQuery) || trabajador.contains(searchQuery);
      }).toList();
    });
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
            onChanged: _filterAppointments,
          ),),
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height*0.7,
          child: ListView.builder(
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              return AppointmentCard(appointment: filteredAppointments[index]);
            },
          ),
        )

      ],),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.pop(context);
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

class AppointmentCard extends StatefulWidget {
  final Appointment appointment;


  AppointmentCard({required this.appointment});

  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard>{

  String codigo_cliente ="0";
  String dni_seleccionado ="";
  String cliente_seleccionado ="";
  String cod_tipodoc = "5";
  String cod_tipopago = "1";
  String totalventa = "0";

  void _mostrarDialogoOpciones(String codigo) async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecciona una opción'),
        content: Text('¿Qué deseas hacer con esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancelar'),
            child: Text('Cancelar Reserva', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('pagar'),
            child: Text('Pagar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      print("Opción seleccionada: $resultado");
      // Aquí puedes manejar la lógica según la opción seleccionada
      if (resultado == 'cancelar') {
        await cancelarVentas(codigo, "C");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva cancelada.')));
      } else if (resultado == 'pagar') {
        //Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            String selectedPaymentMethod = "Efectivo";
            String selectedDocMethod = "Boleta Simple";
            TextEditingController amountController = TextEditingController();
            TextEditingController clientController = TextEditingController();
            TextEditingController dniController = TextEditingController();
            amountController.text = widget.appointment.precio;
            return AlertDialog(
              title: Text("Cerrar Cita"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                        if(value == "Efectivo"){
                          cod_tipopago = "1";
                        }else if(value == "Tarjeta"){
                          cod_tipopago = "2";
                        }else if(value == "Yape"){
                          cod_tipopago = "3";
                        }else if(value == "Transferencia"){
                          cod_tipopago = "4";
                        }else if(value == "Plin"){
                          cod_tipopago = "5";
                        }
                      });

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
                    onChanged: (val){
                      setState(() {
                        totalventa = val;
                      });

                    },
                  ),
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
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async{
                    await registerVentas(cod_tipopago, totalventa, cod_tipodoc, widget.appointment.codproducto,widget.appointment.precio, widget.appointment.codigo );

                    Navigator.pop(context,"true");
                  },
                  child: Text("Confirmar"),
                ),
              ],
            );
          },
        );
      }
    }
  }
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

  Future<void> registerVentas(String codtipopago, String total, String codtipodoc, String codigo_producto, String precio, String codigo_reserva) async {
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
        "txtfecha":DateFormat('yyyy-MM-dd').format(now), "txtserie":"001","txtdocumento":"1", "txtsucursal": idsucursal, "txtusuario":idusuario_capturado,
        "cbotipodoc":codtipodoc, "cbotipoventa":"Contado", "txtcodigocliente":codigo_cliente, "txtdni":dni_seleccionado, "txtnombres":cliente_seleccionado, "txtdireccion":"-", "txtletras":"-",
        "cbotventa": "E","codtipopago":codtipopago,"product": codigo_producto,
        "medida": "UND",
        "sucursal": idsucursal,
        "cantidad": "1",
        "precio": total,
        "subtotal": total,
        "ganancia": "0",
        "detalle": ""
      });

      if (response.statusCode == 200) {
        var rptaJson = json.decode(response.body);
        await atenderVentas(rptaJson["datos"], codtipodoc,idsucursal,codigo_cliente,cliente_seleccionado, "-",dni_seleccionado, codtipopago, DateFormat('yyyy-MM-dd').format(now), total);
        await cancelarVentas(codigo_reserva, "R");
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
        "nro_venta":nro_venta, "tipo":tipo, "sucursal":sucursal, "codigo_cliente":codigo_cliente, "nombres":nombres, "direccion":direccion, "dni":dni, "cod_tipopago":cod_tipopago, "fecha":fecha, "total":total
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

  Future<void> cancelarVentas(String nro_venta, String tipo) async {
    if(tipo == "C"){
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
                Text('registrando operacion...'),
              ],
            ),
          );
        },
      );
    }


    try {

      final response = await http.post(Uri.parse("$url_base/cancelar.cita.php"), body: {
        "codigo":nro_venta, "tipo":tipo
      });

      if (response.statusCode == 200) {
        // var rptaJson = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita cancelada correctamente.')),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cancelar cita.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),

      );
      // return [];
    }
    if(tipo == "C"){
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          color: widget.appointment.estado == "E" ? Colors.blue.shade800: widget.appointment.estado == "C" ? Colors.red: Colors.green,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appointment.clientName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  widget.appointment.dateTime,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  widget.appointment.doctor,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        back: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          color: widget.appointment.estado == "E" ? Colors.blue.shade800: widget.appointment.estado == "C" ? Colors.red: Colors.green,
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
                Text("Tratamiento: ${widget.appointment.treatment}", style: TextStyle(color: Colors.white70, fontSize: 16)),
                Row(
                  children: [
                    Visibility(
                        visible: widget.appointment.estado == 'E' ? true : false,
                        child: ElevatedButton(
                          onPressed: () {
                            _mostrarDialogoOpciones(widget.appointment.codigo);
                          },
                          child: Text("Cerrar Cita", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                        )),
                    const SizedBox(width: 10,),
                    Visibility(
                      visible: widget.appointment.estado == 'E' || widget.appointment.estado == 'R' ? true : false,
                        child:
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HistoriaClinicaScreen(idcita: widget.appointment.codigo,tratamientos: widget.appointment.tratamientos, antecedentes: widget.appointment.antecedentes,diagnostico: widget.appointment.diagnosticos,)),
                        );

                      },
                      child: Text("Agregar detalle", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                    ))
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}





