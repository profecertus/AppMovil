import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prueba_sun_fruits/callService/direcciones.dart';
import 'package:prueba_sun_fruits/callService/services.dart';
import 'package:prueba_sun_fruits/login_new.dart';
import 'package:prueba_sun_fruits/principal_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  Aplicacion parseAplicacion(String responseBody) {
    final parsed = jsonDecode(responseBody);
    Aplicacion app =  Aplicacion.fromJson(parsed);
    return app;
  }

  Future<Aplicacion> getLastVerion(http.Client client) async {
    var endpointUrl = Uri.parse(Direcciones().getUrlPrd( Servicios.validaVer ));
    final response = await client.get(endpointUrl);
    Aplicacion rpta = parseAplicacion(response.body);
    return rpta;
  }

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  //Variables
  String? _selectValTipoDoc = "DNI";
  final List _listaDocumentos = ["DNI"];
  final _textControllerDocumento = TextEditingController();
  final _textControllerPassword = TextEditingController();
  final _textControllerMail = TextEditingController();
  bool _isVisible = false;
  double tamanno = 0.0;
  late Respuesta _respuesta;

  void showLoad(double valor) {
    setState(() {
      tamanno = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    widget.getLastVerion(http.Client()).then((value) {
      //Actualizar la Version ACA
      if (value.num_version != 0.01){
        showDialog(context: context,
            builder:(BuildContext context){
              return AlertDialog(
                title: const Text('Nueva versión móvil'),
                content: const Text('SunFruits ha actualizado el app-móvil.\n'
                    'para continuar disfrutando de la nueva \n'
                    'versión le pedimos actualice.\n'
                    'Esta versión queda inhabilitada.'),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Actualizar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      exit(0);
                    },
                  ),
                ],
              );
            }
        );
        return null;
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('eSun Móvil - Autenticación'),
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: <Widget>[
          Container(
            height: screenHeight * 0.6,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Image.asset(
                        'assets/logo.png',
                        width: screenWidth * 0.5,
                        height: 50,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    DropdownButton(
                      //dropdownColor: Colors.blue[100],
                      iconSize: 36,
                      value: _selectValTipoDoc,
                      onChanged: (newValue) {
                        setState(() {
                          _selectValTipoDoc = newValue as String?;
                        });
                      },
                      items: _listaDocumentos.map((valueItem) {
                        return DropdownMenuItem(
                          value: valueItem,
                          child: Text(valueItem),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Container(
                    alignment: Alignment.topLeft,
                    child: TextFormField(
                      controller: _textControllerDocumento,
                      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                      maxLength: 8,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Número documento',
                          suffixIcon: IconButton(
                              onPressed: () {
                                _textControllerDocumento.clear();
                              },
                              icon: const Icon(Icons.clear))),
                    )),
                Container(
                    alignment: Alignment.topLeft,
                    child: TextFormField(
                      controller: _textControllerPassword,
                      obscureText: !_isVisible,
                      maxLength: 10,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              },
                              icon: _isVisible
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off))),
                    )),
                Container(
                    alignment: Alignment.center,
                    child: const Text(
                        'Urano - v 0.02',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold),
                      ),
                ),
                Container(
                    alignment: Alignment.center,
                    child: TextButton(
                      child: const Text(
                        'Olvidé mi contraseña',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        'Ingrese su correo electónico',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(height: 15),
                                      TextField(
                                        style: const TextStyle(fontSize: 20),
                                        autofocus: true,
                                        controller: _textControllerMail,
                                        decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  _textControllerMail.clear();
                                                },
                                                icon: const Icon(Icons.mail))),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              _textControllerMail.clear();
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async{
                                              if(_textControllerMail.text.isEmpty ||
                                                  !_textControllerMail.text.contains('@') ||
                                                  !_textControllerMail.text.contains('.')){
                                                Fluttertoast.showToast(
                                                    msg: 'Debe de ingresar un correo electrónico válido.',
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.black,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                                return;
                                              }
                                              if (_textControllerMail
                                                  .text.isNotEmpty &&
                                                  _textControllerMail.text
                                                      .contains('@')) {
                                                //Enviar el correo al ws

                                                var endpointUrl = Uri.parse(
                                                    '${Direcciones().getUrlPrd(Servicios.olvidarPassword)}?direccionMail=${_textControllerMail.text}');

                                                Future<String> fetchGet() async {
                                                  final response = await http.Client().get(endpointUrl,
                                                      headers: {
                                                        "Accept": "application/json",
                                                        "content-type": "application/json"
                                                      });
                                                  if (response.statusCode == 200) {
                                                    // Si el servidor devuelve una repuesta OK, parseamos el JSON
                                                    return response.body;
                                                  } else {
                                                    // Si esta respuesta no fue OK, lanza un error.
                                                    throw Exception('Fallo al cargar el POST');
                                                  }
                                                }

                                                String respuesta = await fetchGet();

                                                Fluttertoast.showToast(
                                                    msg: respuesta.replaceAll('"', ''),
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                    Colors.black,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              }
                                              _textControllerMail.clear();
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Enviar',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.purple),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    )),

                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('INGRESAR'),
                    onPressed: () async {
                      var body = jsonEncode({
                        '_tipoDocumento': _selectValTipoDoc,
                        '_numDocumento': _textControllerDocumento.text,
                        '_password': _textControllerPassword.text
                      });

                      var endpointUrl =
                      Uri.parse(Direcciones().getUrlPrd(Servicios.validar));
                      Future<Respuesta> fetchPost() async {
                        final response = await http.post(endpointUrl,
                            body: body,
                            headers: {
                              "Accept": "application/json",
                              "content-type": "application/json"
                            });
                        if (response.statusCode == 200) {
                          // Si el servidor devuelve una repuesta OK, parseamos el JSON
                          _respuesta =
                              Respuesta.fromJson(json.decode(response.body));
                          return _respuesta;
                        } else {
                          // Si esta respuesta no fue OK, lanza un error.
                          throw Exception('Fallo al momento de cargar');
                        }
                      }

                      showLoad(MediaQuery.of(context).size.height);
                      await fetchPost();
                      if (context.mounted) {
                        showLoad(0);
                        if (_respuesta.success && _respuesta.resultado.length > 0) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => PrincipalPage(
                                  respuesta: _respuesta,
                                )),
                          );
                        }else{
                          Fluttertoast.showToast(
                              msg: 'Sus credenciales no son válidas, verifique.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Error al momento de validar',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                  ),
                ),
                /*
                Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes una cuenta? ',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                              const LoginNew(),
                            ),
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ])),
                */
              ],
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              height: tamanno,
              color: Colors.grey.withOpacity(0.7),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: null,
                  ),
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Validando su usuario',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
