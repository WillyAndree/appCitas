import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prycitas/constants.dart';
import 'package:prycitas/view/cajaList.dart';
import 'package:prycitas/view/citasList.dart';
import 'package:prycitas/view/clientesList.dart';
import 'package:prycitas/view/loginpage.dart';
import 'package:prycitas/view/productList.dart';
import 'package:prycitas/view/ventasList.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prycitas/model/utils/location_notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:prycitas/view/notifications/notifications_page.dart' as noti;
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  List sales = [];
  static String? token;
  String? token_movil;
  List clients = [];
  List products = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      solicitarPermisos();
      LocalNotificationService.initialize(context);
      mostrarNotificacion();
      DateTime actual = DateTime.now();
     fetchVentas();
     fetchClientes(actual.month);
      fetchProductos(actual.month);
    });
  }

  void solicitarPermisos() async {
    try {
        var status = await Permission.notification.status;
        if (!status.isGranted) {
          status = await Permission.notification.request();
        }
        if (status.isGranted) {
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            badge: true,
            provisional: false,
            sound: true,
          );

          token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            token_movil = token!;
            print("TOKEN: $token");
          } else {
            print("No se pudo obtener el token.");
          }
        } else {
          print("No se otorgaron los permisos necesarios.");
        }
    } catch (e) {
      print("Error al solicitar permisos o obtener el token: $e");
    }
  }

  Future<void>mostrarNotificacion() async{

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("NOTIFICACION 2 : "+message.notification!.title!);
      noti.NotificationService().addNotification(noti.Notification(
        id: message.senderId.toString(),
        title: message.notification!.title!,
        body: message.notification!.body!,
        data: message.data["id"],
        cliente: message.data["cliente"],
        trabajador: message.data["trabajador"],
        timestamp: DateTime.now(),
        hora: message.data["hora"]??"",
      ));
      LocalNotificationService().showNotification(title: message.notification!.title.toString(), body: message.notification!.body.toString(), payload: message.data["route"],);


    });

    FirebaseMessaging.onMessage.listen((message) async{
      noti.NotificationService().addNotification(noti.Notification(
        id: message.senderId.toString(),
        title: message.notification!.title!,
        body: message.notification!.body!,
        data: message.data["id"],
        cliente: message.data["cliente"],
        trabajador: message.data["trabajador"],
        timestamp: DateTime.now(),
        hora: message.data["hora"]??"",
      ));

     LocalNotificationService().showNotification(title: message.notification!.title.toString(), body: message.notification!.body.toString(), payload: message.data["route"],);


    });
  }

  Future<void> fetchVentas() async {
    try {


      final response = await http.post(Uri.parse("$url_base/dashboard.listar.grafico.lineal.php"), body: {
        "sucursal":idsucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var sellJson = rptaJson["datos"] ?? [];
        if ( sellJson.isEmpty) {
          setState((){
            sales.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron ventas.')),
          );
          return;
        }else{
          setState((){
            sales.clear();
          });


          for(int i = 0; i <sellJson.length; i++){
            setState(() {
              sales.add( {
                "1": sellJson[i]["enero"],
                "2": sellJson[i]["febrero"],
                "3": sellJson[i]["marzo"],
                "4": sellJson[i]["abril"],
                "5": sellJson[i]["mayo"],
                "6": sellJson[i]["junio"],
                "7": sellJson[i]["julio"],
                "8": sellJson[i]["agosto"],
                "9": sellJson[i]["setiembre"],
                "10": sellJson[i]["octubre"],
                "11": sellJson[i]["noviembre"],
                "12": sellJson[i]["diciembre"]
              });

            });
          }
        }


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ventas.')),
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
  Future<void> fetchClientes(int mes) async {
    try {


      final response = await http.post(Uri.parse("$url_base/dashboard.listar.clientes.top.php"), body: {
        "mes":mes.toString(),"sucursal":idsucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var sellJson = rptaJson["datos"] ?? [];
        if ( sellJson.isEmpty) {
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


          for(int i = 0; i <sellJson.length; i++){
            setState(() {
              clients.add( {
                "cliente": sellJson[i]["cliente"],
                "total": sellJson[i]["total"],
              });

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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // return [];
    }
  }
  Future<void> fetchProductos(int mes) async {
    try {


      final response = await http.post(Uri.parse("$url_base/dashboard.listar.productos.top.php"), body: {
        "mes":mes.toString(),"sucursal":idsucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var sellJson = rptaJson["datos"] ?? [];
        if ( sellJson.isEmpty) {
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


          for(int i = 0; i <sellJson.length; i++){
            setState(() {
              products.add( {
                "producto": sellJson[i]["producto"],
                "total": sellJson[i]["total"],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text("Gestión de Citas")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/PODOLOGIA.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Citas"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentListScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text("Clientes"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ClientListScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Productos"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text("Caja"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CashboxScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text("Ventas"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SalesListScreen()));
              },
            ),
            Divider(thickness: 3,),
            ListTile(
              leading: Icon(Icons.door_back_door_rounded),
              title: Text("Cerrar Sesión"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(child: Text("Nivel de Ventas", style: TextStyle(fontWeight: FontWeight.bold),),),
          Expanded(child: SalesChart(data: sales,)),
          SizedBox(height: 20,),
          Divider(thickness: 3,),
          Container(child: Text("TOP CLIENTES", style: TextStyle(fontWeight: FontWeight.bold)),),
          Expanded(child: TopClientsChart(data: clients,)),
          SizedBox(height: 20,),
          Divider(thickness: 3,),
          Container(child: Text("TOP PRODUCTOS", style: TextStyle(fontWeight: FontWeight.bold)),),
          Expanded(child: TopProductsChart(data:products)),
        ],
      ),
    );
  }
}


class SalesChart extends StatefulWidget {
  List data = [];
  SalesChart({super.key, required this.data});

  @override
  _SalesChartState createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const meses = [
                      '', // Índice 0 no se usa
                      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
                    ];
                    return Text(
                      value.toInt() >= 1 && value.toInt() <= 12 ? meses[value.toInt()] : '',
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 50,
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('S/.${value.toInt()}',
                      style: TextStyle(fontSize: 11),),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(1, widget.data.isNotEmpty ? double.parse(widget.data[0]["1"]): 0 ),
                  FlSpot(2,  widget.data.isNotEmpty ? double.parse(widget.data[0]["2"]): 0),
                  FlSpot(3,  widget.data.isNotEmpty ? double.parse(widget.data[0]["3"]): 0),
                  FlSpot(4,  widget.data.isNotEmpty ? double.parse(widget.data[0]["4"]): 0),
                  FlSpot(5,  widget.data.isNotEmpty ? double.parse(widget.data[0]["5"]): 0),
                  FlSpot(6,  widget.data.isNotEmpty ? double.parse(widget.data[0]["6"]): 0),
                  FlSpot(7,  widget.data.isNotEmpty ? double.parse(widget.data[0]["7"]): 0),
                  FlSpot(8,  widget.data.isNotEmpty ? double.parse(widget.data[0]["8"]): 0),
                  FlSpot(9,  widget.data.isNotEmpty ? double.parse(widget.data[0]["9"]): 0),
                  FlSpot(10, widget.data.isNotEmpty ? double.parse(widget.data[0]["10"]): 0),
                  FlSpot(11, widget.data.isNotEmpty ? double.parse(widget.data[0]["11"]): 0),
                  FlSpot(12, widget.data.isNotEmpty ?double.parse(widget.data[0]["12"]): 0),
                ],
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: true),
              ),
            ],
          )

      ),
    );
  }
}

class TopClientsChart extends StatefulWidget {
  List data = [];
  TopClientsChart({super.key, required this.data});

  @override
  _TopClientsChartState createState() => _TopClientsChartState();
}

class _TopClientsChartState extends State<TopClientsChart> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 1:
                  return widget.data.isNotEmpty ? Text(widget.data.length > 0 ? widget.data[0]["cliente"] : ""): Text("");
                case 2:
                  return widget.data.isNotEmpty ? Text(widget.data.length > 1 ? widget.data[1]["cliente"]: ""): Text("");
                case 3:
                  return widget.data.isNotEmpty ? Text(widget.data.length > 2 ?widget.data[2]["cliente"]: "")  :Text("");
                default:
                  return Text("");
              }
            })),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: widget.data.isNotEmpty ? widget.data.length > 0 ? double.parse(widget.data[0]["total"]) :0 : 0, color: Colors.red)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: widget.data.isNotEmpty ? widget.data.length > 1 ? double.parse(widget.data[1]["total"]): 0: 0, color: Colors.green)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: widget.data.isNotEmpty ? widget.data.length > 2 ? double.parse(widget.data[2]["total"]): 0: 0, color: Colors.blue)]),
          ],
        ),
      ),
    );
  }
}

class TopProductsChart extends StatefulWidget {
  List data = [];
  TopProductsChart({super.key, required this.data});

  @override
  _TopProductsChartState createState() => _TopProductsChartState();
}

class _TopProductsChartState extends State<TopProductsChart> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 1:
                  return widget.data.isNotEmpty ? Text(widget.data.length > 0 ? widget.data[0]["producto"] : ""): Text("");
                case 2:
                  return widget.data.isNotEmpty ? Text(widget.data.length > 1 ? widget.data[1]["producto"] : ""): Text("");
                case 3:
                  return widget.data.isNotEmpty ? Text(widget.data.length > 2 ? widget.data[2]["profucto"] : ""): Text("");
                default:
                  return Text("");
              }
            })),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: widget.data.isNotEmpty ? widget.data.length > 0 ? double.parse(widget.data[0]["total"]) :0 : 0,
                  color: Colors.red,
                  width: 20,  // Ajusta el ancho de las barras
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: widget.data.isNotEmpty ? widget.data.length > 1 ? double.parse(widget.data[1]["total"]) :0 : 0,
                  color: Colors.green,
                  width: 15,  // Ajusta el ancho de las barras
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: widget.data.isNotEmpty ? widget.data.length > 2 ? double.parse(widget.data[2]["total"]) :0 : 0,
                  color: Colors.blue,
                  width: 15,  // Ajusta el ancho de las barras
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
