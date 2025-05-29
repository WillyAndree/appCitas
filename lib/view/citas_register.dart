import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prycitas/constants.dart';
import 'package:prycitas/view/citasList.dart';

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
  String idcliente = "0";
  String idtrabajador = "0";
  String idtreatments = "0";

  String? cliente_seleccionado = "SELECCIONE UN CLIENTE";

  final List<String> treatments = [];
  final List treatmentsall = [];
  final List<String> workers = [];
  final List workersall = [];
  final List<String> availableTimes = ["08:00 AM","09:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "13:00 pM", "15:00 PM", "16:00 PM", "17:00 PM", "18:00 PM", "19:00 PM", "20:00 PM"];
  final List<String> occupiedTimes = [];
  final List clients = [];
  final List<String> clientsname = [];


  Future<void> fetchClientes(String cliente) async {
    try {
      final response = await http.post(Uri.parse("$url_base/cliente.listar.nombres.php"), body: {
        "nombres":cliente
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var clientesJson = rptaJson["datos"] ?? [];
        if ( clientesJson.isEmpty) {
          setState((){
            clients.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron clientes.')),
          );
          return;
        }else{
          setState((){
            clients.clear();
          });


          for(int i = 0; i <clientesJson.length; i++){
            setState(() {
              clients.add({
                "codigo":clientesJson[i]["codigo"],
                "nombres":clientesJson[i]["nombres"]
              });
              clientsname.add(clientesJson[i]["nombres"].toString());
            });
          }
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener clientes.')),
        );
        // return [];
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // return [];
    }
  }

  Future<void> registerCitas(String idcliente, idtrabajador, idproducto, fecha,hora, idusuario) async {
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
              Text('Registrando cita...'),
            ],
          ),
        );
      },
    );
    try {
      final response = await http.post(Uri.parse("$url_base/citas.agregar.php"), body: {
        "idcliente":idcliente, "idtrabajador":idtrabajador, "idproducto": idproducto, "fecha":fecha, "hora":hora, "idusuario": idusuario, "idsucursal": idsucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var rptJson = rptaJson["datos"] ?? [];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita registrada correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar cita.')),
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

  Future<void> fetchCitasOcupadas(String fecha) async {

    try {
      final response = await http.post(Uri.parse("$url_base/citas.ocupadas.php"), body: {
        "fecha":fecha, "idsucursal":idsucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var ocupaJson = rptaJson["datos"] ?? [];
        if ( ocupaJson.isEmpty) {
          setState((){
            occupiedTimes.clear();
          });
          return;
        }else{
          setState((){
            occupiedTimes.clear();
          });


          for(int i = 0; i <ocupaJson.length; i++){
            setState(() {

              occupiedTimes.add(ocupaJson[i]["hora"].toString());
            });
          }
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener horarios.')),
        );
        // return [];
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // return [];
    }
  }

  Future<void> fetchTrabajadores() async {
    try {
      final response = await http.get(Uri.parse("$url_base/colaborador.listar.nombres.php"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var clientesJson = rptaJson["datos"] ?? [];
        if ( clientesJson.isEmpty) {
          setState((){
            workers.clear();
            workersall.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron colaboradores.')),
          );
          return;
        }else{
          setState((){
            workersall.clear();
            workers.clear();
          });


          for(int i = 0; i <clientesJson.length; i++){
            setState(() {
              workersall.add({
                "codigo":clientesJson[i]["codigo"],
                "nombres":clientesJson[i]["nombres"]
              });
              workers.add(clientesJson[i]["nombres"].toString());
            });
          }
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener colaboradores.')),
        );
        // return [];
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // return [];
    }
  }

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
            treatmentsall.clear();
            treatments.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron productos.')),
          );
          return;
        }else{
          setState((){
            treatmentsall.clear();
            treatments.clear();
          });


          for(int i = 0; i <productsJson.length; i++){
            setState(() {
              treatmentsall.add({
                "codigo":productsJson[i]["codigo"],
                "nombres":productsJson[i]["nombre"],
                "stock":productsJson[i]["stock"],
                "precio":productsJson[i]["precio"],
                "estado":productsJson[i]["estado"]
              });

              treatments.add(productsJson[i]["nombre"]);
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
    WidgetsBinding.instance.addPostFrameCallback((_) async{
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
                Text('Cargando datos de citas...'),
              ],
            ),
          );
        },
      );
      await fetchClientes("");
      await fetchTrabajadores();
      await fetchProducts("");
      Navigator.pop(context);
    });

  }
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
        Container(
        decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(15)), boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3.0,
            offset: Offset(0.0, 5.0),
          )
        ]),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        width: MediaQuery.sizeOf(context).width,
        child: DropdownSearch<String>(
          selectedItem:cliente_seleccionado,
          popupProps: const PopupProps.menu(

              showSelectedItems: true,
              showSearchBox: true,
              searchFieldProps:  TextFieldProps(
                  style: TextStyle(fontSize: 14,fontFamily: "Schyler" ),
                  cursorColor: Colors.blue
              )
          ),
          items: clientsname,
          dropdownDecoratorProps:  const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(prefixIcon: Icon(Icons.search),border: InputBorder.none,
                  hintText: "SELECCIONE UN CLIENTE",labelStyle: TextStyle(fontSize: 14,fontFamily: "Schyler"))),
          onChanged: (val) async{
            print(val);
            for(int i = 0; i<clients.length; i++){
              if(clients[i]["nombres"] == val){
                idcliente = clients[i]["codigo"];
              }
            }
          },

        ),
      ),
            /*TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre del Paciente"),
            ),*/
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
                            Text('Cargando horarios disponibles...'),
                          ],
                        ),
                      );
                    },
                  );
                  await fetchCitasOcupadas("${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}");
                  Navigator.pop(context);
                }
              },
            ),
            Visibility(
              visible: selectedDate == null ? false: true,
                child: Wrap(
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
            )),
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
                  for(int i = 0; i<treatmentsall.length; i++){
                    if(treatmentsall[i]["nombres"] == value){
                      idtreatments = treatmentsall[i]["codigo"];
                    }
                  }
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
                  for(int i = 0; i<workersall.length; i++){
                    if(workersall[i]["nombres"] == value){
                      idtrabajador = workersall[i]["codigo"];
                    }
                  }
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
              onPressed: () async{
                await registerCitas(idcliente,idtrabajador,idtreatments,DateFormat("yyyy-MM-dd").format(selectedDate!),selectedTime,idusuario_capturado);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentListScreen()),
                );
              },
              child: Text("Guardar Cita", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
