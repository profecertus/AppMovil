import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba_sun_fruits/boletas/BoletaList.dart';
import 'package:http/http.dart' as http;
import '../callService/direcciones.dart';
import '../callService/services.dart';
import '../main.dart';

class BoletaView extends StatefulWidget {
  final Respuesta respuesta;
  const BoletaView({Key? key, required this.respuesta}) : super(key: key);

  @override
  State<BoletaView> createState() => _BoletaViewState();
}


class _BoletaViewState extends State<BoletaView> {
  List<Documento> _foundUsers = [];
  List<Documento> _allUsers = [];

  Future<List<Documento>> getDocumentos(http.Client client) async {
    var endpointUrl = Uri.parse(
        '${Direcciones().getUrlPrd(Servicios.getDocumentos)}?tipoDocumento=${widget.respuesta
            .resultado[0]['tipo_documento']}&numeroDocumento=${widget.respuesta
            .resultado[0]['numero_documento']}');

    final response = await client.get(endpointUrl);
    List<Documento> rpta = parseDocumentos(response.body);
    return rpta;
  }

  List<Documento> parseDocumentos(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Documento>((json) => Documento.fromJson(json)).toList();
  }


  @override
  initState() {
    super.initState();
    getDocumentos(http.Client()).then((value) {
      setState((){
        _allUsers = value;
        _foundUsers = _allUsers;
      });
    });
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Documento> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
          user.periodo.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Palette.kToDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        hintText: 'Búsqueda por periodo',
                      ),
                      onChanged: (value) => _runFilter(value),
                    ),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                  itemCount: _foundUsers.length,
                  itemBuilder: (context, index) {
                    return BoletaList(
                      _foundUsers[index],
                    );
                  })
                  : const Text(
                'Sin boletas encontradas',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}