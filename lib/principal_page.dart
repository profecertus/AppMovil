import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prueba_sun_fruits/boletas/BoletaView.dart';
import 'package:prueba_sun_fruits/callService/direcciones.dart';
import 'package:prueba_sun_fruits/callService/services.dart';
import 'package:prueba_sun_fruits/main.dart';
import 'package:prueba_sun_fruits/notificaciones/NotificacionView.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_fgbg/flutter_fgbg.dart';

class PrincipalPage extends StatefulWidget {
  final Respuesta respuesta;
  const PrincipalPage({required this.respuesta, super.key});
  @override
  State<StatefulWidget> createState() => _PrincipalPage();
}

class _PrincipalPage extends State<PrincipalPage> {
  int _selectedDrawerIndex = 0;
  String _tituloApp = '';
  bool _isVisiblePassAct = false;
  bool _isVisiblePassNew0 = false;
  bool _isVisiblePassNew1 = false;
  final _textControllerPassAct = TextEditingController();
  final _textControllerPassNew0 = TextEditingController();
  final _textControllerPassNew1 = TextEditingController();
  String _textStringError = '';
  final _formKey = GlobalKey<FormState>();

  _getDrawerItemWidget(int pos) {
    //print(pos.toString());
    switch (pos) {
      case 0:
        return const NotificacionView();
      case 1:
        return BoletaView(respuesta: widget.respuesta);
      case 2:
        return const NotificacionView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyMedium!;

    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: "Flutter is Google's UI toolkit for building beautiful, "
                    'natively compiled applications for mobile, web, and desktop '
                    'from a single codebase. Learn more about Flutter at '),
            TextSpan(
                style: textStyle.copyWith(color: theme.colorScheme.primary),
                text: 'https://flutter.dev'),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('eSun Móvil$_tituloApp'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Salida del App'),
                    content: const Text('¿Seguro que desea salir del App?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'NO'),
                        child: const Text('NO'),
                      ),
                      TextButton(
                        onPressed: () => exit(0),
                        child: const Text('SI'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 200.0,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/default-avatar.png'),
                    scale: 4,
                    fit: BoxFit.scaleDown,
                  ),
                  color: Palette.kToDark,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.respuesta.resultado[0]['nombres']} ${widget.respuesta.resultado[0]['apellidos']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.file_present,
              ),
              title: const Text(
                'Boletas de pago',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = 1;
                  _tituloApp = ' - Boletas de Pago';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.art_track,
              ),
              title: const Text(
                'Notificaciones',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = 2;
                  _tituloApp = ' - Notificaciones';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
                leading: const Icon(
                  Icons.password,
                ),
                title: const Text(
                  'Cambio de clave',
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  _textControllerPassAct.text = '';
                  _textControllerPassNew0.text = '';
                  _textControllerPassNew1.text = '';
                  _textStringError = '';

                  AlertDialog alert = AlertDialog(
                    elevation: 24.0,
                    title: const Text(
                      'CAMBIO DE CLAVE',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    scrollable: true,
                    content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Container(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset('assets/logo.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 40,
                                      alignment: Alignment.centerLeft),
                                  TextFormField(
                                    style: const TextStyle(fontSize: 16),
                                    autofocus: true,
                                    controller: _textControllerPassAct,
                                    obscureText: !_isVisiblePassAct,
                                    maxLength: 10,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese la contraseña';
                                      }
                                      if (value !=
                                          widget.respuesta.resultado[0]
                                              ['contrasenna']) {
                                        _textStringError = "La contraseña actual es incorrecta";
                                        return 'Contraseña incorrecta';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      labelText: 'Contraseña actual',
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isVisiblePassAct =
                                                  !_isVisiblePassAct;
                                            });
                                          },
                                          icon: _isVisiblePassAct
                                              ? const Icon(Icons.visibility)
                                              : const Icon(
                                                  Icons.visibility_off)),
                                    ),
                                  ),
                                  TextFormField(
                                    style: const TextStyle(fontSize: 16),
                                    autofocus: true,
                                    controller: _textControllerPassNew0,
                                    obscureText: !_isVisiblePassNew0,
                                    maxLength: 10,
                                    validator: (value) {
                                      if(_textStringError.isNotEmpty)
                                        return null;
                                      RegExp regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$');
                                      if (value == null || value.isEmpty)
                                        return 'Ingrese la contraseña';
                                      if (value.length < 6) {
                                        _textStringError =
                                            'La contraseña nueva debe contener entre 6 y 10 caracteres';
                                        return 'Longitud de Contraseña';
                                      }
                                      if (!regex.hasMatch(value)) {
                                        _textStringError =
                                            'La contraseña nueva debe contener sólo letras y números';
                                        return 'Formato de contraseña';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      labelText: 'Contraseña nueva',
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isVisiblePassNew0 =
                                                  !_isVisiblePassNew0;
                                            });
                                          },
                                          icon: _isVisiblePassNew0
                                              ? const Icon(Icons.visibility)
                                              : const Icon(
                                                  Icons.visibility_off)),
                                    ),
                                  ),
                                  TextFormField(
                                    style: const TextStyle(fontSize: 16),
                                    autofocus: true,
                                    controller: _textControllerPassNew1,
                                    obscureText: !_isVisiblePassNew1,
                                    maxLength: 10,
                                    validator: (value) {
                                      if(_textStringError.isEmpty)
                                        if (value !=
                                            _textControllerPassNew0.text) {
                                          _textStringError =
                                              'Las contraseñas no coinciden';
                                          return 'Las contraseñas no coinciden';
                                        }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      labelText: 'Repita contraseña',
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isVisiblePassNew1 =
                                                  !_isVisiblePassNew1;
                                            });
                                          },
                                          icon: _isVisiblePassNew1
                                              ? const Icon(Icons.visibility)
                                              : const Icon(
                                                  Icons.visibility_off)),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FilledButton(
                                        onPressed: () {
                                          _textControllerPassAct.clear();
                                          Navigator.pop(context);
                                          _isVisiblePassNew0 = false;
                                          _isVisiblePassNew1 = false;
                                          _isVisiblePassAct = false;
                                        },
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      FilledButton(
                                        onPressed: () async {
                                          _isVisiblePassNew0 = false;
                                          _isVisiblePassNew1 = false;
                                          _isVisiblePassAct = false;
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            Fluttertoast.showToast(
                                                msg: _textStringError,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 2,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            _textStringError = '';
                                            return;
                                          }
                                          ;

                                          var body = jsonEncode({
                                            'tipoDocumento': widget.respuesta
                                                .resultado[0]['tipo_documento'],
                                            'numDocumento':
                                                widget.respuesta.resultado[0]
                                                    ['numero_documento'],
                                            'email':
                                                widget.respuesta.resultado[0]
                                                    ['numero_documento'],
                                            'numCelular':
                                                widget.respuesta.resultado[0]
                                                    ['numero_documento'],
                                            'contrasenna':
                                                _textControllerPassNew0.text,
                                            'fechaEmision': ''
                                          });
                                          var endpointUrl = Uri.parse(
                                              Direcciones().getUrlPrd(
                                                  Servicios.cambiarPassword));
                                          Future<Respuesta> fetchPost() async {
                                            final response = await http.post(
                                                endpointUrl,
                                                body: body,
                                                headers: {
                                                  "Accept": "application/json",
                                                  "content-type":
                                                      "application/json"
                                                });
                                            if (response.statusCode == 200) {
                                              widget.respuesta.resultado[0]
                                                      ['contrasenna'] =
                                                  _textControllerPassNew0.text;
                                              // Si el servidor devuelve una repuesta OK, parseamos el JSON
                                              return Respuesta.fromJson(
                                                  json.decode(response.body));
                                            } else {
                                              // Si esta respuesta no fue OK, lanza un error.
                                              throw Exception(
                                                  'Se tiene problemas al contactar con el servidor, verifique su conexión a internet');
                                            }
                                          }

                                          Respuesta respuesta =
                                              await fetchPost();
                                          if (respuesta.success) {
                                            widget.respuesta.resultado[0]
                                                    ['password'] =
                                                _textControllerPassNew1.text;
                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Se modificó correctamente su clave',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Error al momento de cambiar la clave',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: const Text(
                                          '  Enviar  ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ));
                    }),
                  );

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                }),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
              ),
              title: const Text(
                'Salir',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Salida del App'),
                    content: const Text('¿Seguro que desea salir del App?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'NO'),
                        child: const Text('NO'),
                      ),
                      TextButton(
                        onPressed: () => exit(0),
                        child: const Text('SI'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.info,
              ),
              title: const Text(
                'Acerca del app',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text(
                            'Sun Fruits Corporation',
                            style: TextStyle(fontSize: 20),
                          ),
                          content: Text('\u{a9} 2023 Sun Fruits Corporation'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: ()  => Navigator.pop(context, 'CERRAR'),
                              child: Text('CERRAR'),
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
