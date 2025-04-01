import 'package:flutter/material.dart';
import 'package:prycitas/view/cajaList.dart';
import 'package:prycitas/view/citasList.dart';
import 'package:prycitas/view/clientesList.dart';
import 'package:prycitas/view/loginpage.dart';
import 'package:prycitas/view/productList.dart';
import 'package:prycitas/view/ventasList.dart';
import 'package:fl_chart/fl_chart.dart';

class MainScreen extends StatelessWidget {
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
          Expanded(child: SalesChart()),
          SizedBox(height: 20,),
          Divider(thickness: 3,),
          Container(child: Text("TOP CLIENTES", style: TextStyle(fontWeight: FontWeight.bold)),),
          Expanded(child: TopClientsChart()),
          SizedBox(height: 20,),
          Divider(thickness: 3,),
          Container(child: Text("TOP PRODUCTOS", style: TextStyle(fontWeight: FontWeight.bold)),),
          Expanded(child: TopProductsChart()),
        ],
      ),
    );
  }
}


class SalesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, getTitlesWidget: (value, meta) => Text('\$${value.toInt()}'))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('Mes ${value.toInt()}'))),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(1, 50),
                FlSpot(2, 80),
                FlSpot(3, 100),
                FlSpot(4, 150),
                FlSpot(5, 200),
              ],
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

class TopClientsChart extends StatelessWidget {
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
                  return Text("Cliente A");
                case 2:
                  return Text("Cliente B");
                case 3:
                  return Text("Cliente C");
                default:
                  return Text("");
              }
            })),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 300, color: Colors.red)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 250, color: Colors.green)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 200, color: Colors.blue)]),
          ],
        ),
      ),
    );
  }
}

class TopProductsChart extends StatelessWidget {
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
                  return Text("Producto X");
                case 2:
                  return Text("Producto Y");
                case 3:
                  return Text("Producto Z");
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
                  toY: 300,
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
                  toY: 250,
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
                  toY: 200,
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
