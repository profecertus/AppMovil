import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../callService/services.dart';
import '../main.dart';
import 'package:http/http.dart' as http;
import '../callService/direcciones.dart';
import 'NotificacionList.dart';


class NotificacionView extends StatefulWidget {
  const NotificacionView({Key? key}) : super(key: key);

  @override
  State<NotificacionView> createState() => _NotificacionViewState();
}


class _NotificacionViewState extends State<NotificacionView> {
  List<Notificacion> _foundUsers = [];
  List<Notificacion> _allUsers = [];

  Future getNotificaciones(http.Client client) async {
    var endpointUrl = Uri.parse(Direcciones().getUrlPrd( Servicios.getNotificaciones ));
    final response = await client.get(endpointUrl);
    List<Notificacion> rpta = parseNotificacion(response.body);
    return rpta;
  }

  List<Notificacion> parseNotificacion(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Notificacion>((json) => Notificacion.fromJson(json)).toList();
  }

  @override
  initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData()async {
    getNotificaciones(http.Client()).then((value) {
      setState((){
        _allUsers = value;
        _foundUsers = _allUsers;
      });
    });
  }

  void _runFilter(String enteredKeyword) {
    List<Notificacion> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
          user.titulo.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
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
                        hintText: 'Búsqueda de  título por notificación',
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
                    return NotificacionList(
                      _foundUsers[index],
                    );
                  })
                  : const Text(
                'Sin notificaciones encontradas',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      )
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


