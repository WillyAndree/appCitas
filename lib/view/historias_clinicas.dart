import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prycitas/constants.dart';
import 'package:http/http.dart' as http;
import 'package:prycitas/view/citasList.dart';

class HistoriaClinicaScreen extends StatefulWidget {
  String idcita, antecedentes, diagnostico, tratamientos;
  HistoriaClinicaScreen({required this.idcita, required this.antecedentes, required this.diagnostico, required this.tratamientos});
  @override
  _HistoriaClinicaScreenState createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  final TextEditingController antecedentesController = TextEditingController();
  final TextEditingController diagnosticosController = TextEditingController();
  final TextEditingController tratamientosController = TextEditingController();

  void _guardarHistoriaClinica() async{
    String antecedentes = antecedentesController.text;
    String diagnosticos = diagnosticosController.text;
    String tratamientos = tratamientosController.text;

    bool rpta = await registerDetail(antecedentes, diagnosticos, tratamientos,widget.idcita);
    if(rpta){
      Navigator.pop(context);
    }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   antecedentesController.text = widget.antecedentes;
   diagnosticosController.text = widget.diagnostico;
   tratamientosController.text = widget.tratamientos;
  }

  Future<bool> registerDetail(String antecedentes, String diagnosticos, String tratamientos, String idcita) async {
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
              Text('Registrando detalles...'),
            ],
          ),
        );
      },
    );
    try {
      final response = await http.post(Uri.parse("$url_base/detalle.cita.agregar.php"), body: {
        "antecedentes":antecedentes, "diagnosticos":diagnosticos, "tratamientos": tratamientos, "idcita":idcita
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var rptJson = rptaJson["datos"] ?? [];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detalle registrado correctamente.')),
        );
        Navigator.pop(context);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar detalle.')),
        );
        Navigator.pop(context);
        return false;
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      Navigator.pop(context);
      return false;
      // return [];
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        title: Text('Historia Clínica'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
                context,
            MaterialPageRoute(builder: (context) => AppointmentListScreen()));
          }
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCampoTexto("Antecedentes", antecedentesController),
            SizedBox(height: 10),
            _buildCampoTexto("Diagnósticos", diagnosticosController),
            SizedBox(height: 10),
            _buildCampoTexto("Tratamientos", tratamientosController),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _guardarHistoriaClinica,
              icon: Icon(Icons.save, color: Colors.white,),
              label: Text("Guardar", style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
    );
  }
}
