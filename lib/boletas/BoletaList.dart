import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prueba_sun_fruits/callService/direcciones.dart';
import '../callService/services.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:http/http.dart' as http;

class BoletaList extends StatefulWidget {
  final Documento child;

  const BoletaList(this.child, {super.key});

  @override
  State<BoletaList> createState() => _BoletaList();
}

class _BoletaList extends State<BoletaList> {
  File? fileCreado;
  late Respuesta _respuesta;
  Future<File> createFileOfPdfUrl(String url) async {
    Completer<File> completer = Completer();
    try {
      const filename = "BoletaDescargada.pdf";
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      fileCreado = File("${dir.path}/$filename");

      await fileCreado?.writeAsBytes(bytes, flush: true);
      completer.complete(fileCreado);
    } catch (e) {
      throw Exception('Error parseando el archivo');
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    double tamanno = 0.0;
    bool _isVisible = false;
    final _textControllerPassword = TextEditingController();

    showAlertDialog(BuildContext context, Documento doc) {
      _textControllerPassword.text = "";
      Widget okSi = TextButton(
        child: const Text("Recepcionar"),
        onPressed: () async {
          var body = jsonEncode({
            '_tipoDocumento': widget.child.tipoDocumento,
            '_numDocumento': widget.child.numeroDocumento,
            '_password': _textControllerPassword.text
          });

          var endpointValidar =
              Uri.parse(Direcciones().getUrlPrd(Servicios.validar));
          var endpointUrl = Uri.parse(
              '${Direcciones().getUrlPrd(Servicios.saveFirma)}?IdReporte=${widget.child.idDocumento.toString()}');

          Future<Respuesta> validarGet() async {
            final response = await http.post(endpointValidar,
                body: body,
                headers: {
                  "Accept": "application/json",
                  "content-type": "application/json"
                });
            if (response.statusCode == 200) {
              // Si el servidor devuelve una repuesta OK, parseamos el JSON
              _respuesta = Respuesta.fromJson(json.decode(response.body));
              return _respuesta;
            } else {
              // Si esta respuesta no fue OK, lanza un error.
              throw Exception('Se tiene problemas al contactar con el servidor, por favor verifique su conexión a internet');
            }
          }

          Future<Respuesta> fetchPost() async {
            final response = await http.post(endpointUrl, headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            });
            if (response.statusCode == 200) {
              // Si el servidor devuelve una repuesta OK, parseamos el JSON
              _respuesta = Respuesta.fromJson(json.decode(response.body));
              return _respuesta;
            } else {
              // Si esta respuesta no fue OK, lanza un error.
              throw Exception('Se tiene problemas al momento de contactar con el servidor, por favor verifique la conexión');
            }
          }

          await validarGet();
          if (context.mounted) {
            if (this._respuesta.success) {
              await fetchPost();
              if (context.mounted) {
                if (_respuesta.success) {
                  Fluttertoast.showToast(
                      msg: 'Se recepciono su boleta de ${widget.child.periodo}',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0);

                  setState(() {
                    doc.recibido = 'S';
                  });
                }
              }
            } else {
              Fluttertoast.showToast(
                  msg: 'Contraseña incorrecta',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.black,
                  fontSize: 16.0);
              return;
            }
          }
          Navigator.of(context, rootNavigator: true).pop();
        },
      );

      Widget okNo = TextButton(
        child: const Text("Cancelar"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        elevation: 24.0,
        title: Text(
          'BOLETA - ${doc.periodo}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Ingrese su contraseña para recepcionar su boleta'),
            TextFormField(
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
                          //print(_isVisible);
                        });
                      },
                      icon: _isVisible
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off))),
            ),
          ]);
        }),
        actions: [okNo, okSi],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(children: <Widget>[
        Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 160,
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey, width: 1, style: BorderStyle.solid),
            ),
            //color: Colors.deepPurple[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () async {
                      if (widget.child.recibido != 'S') {
                        showAlertDialog(context, widget.child);
                        return;
                      }
                      /*Muestro la ventana de Carga de Boletas*/
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Scaffold(
                                  body: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      color: Colors.grey.withOpacity(0.7),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.4,
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
                                            'Cargando su boleta',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          )
                                        ],
                                      )),
                                )),
                      );

                      await createFileOfPdfUrl(
                          '${Direcciones().getUrlPrd(Servicios.getPDF)}?idDocumento=${widget.child.idDocumento}');
                      if (context.mounted) {
                        Future<int>? tamanno = fileCreado?.length();
                        if (context.mounted) {
                          tamanno?.then((value) {
                            Navigator.pop(context);
                            if (value != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFScreen(
                                    path: fileCreado?.path,
                                    fileCreado: fileCreado,
                                    nombre: widget.child.nombreDocumento,
                                    periodo: widget.child.periodo,
                                  ),
                                ),
                              );
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      'Se tiene problemas al momento de cargar su boleta, intentelo en unos minutos',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          });
                        }
                      }
                    }, // Image tapped
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const FaIcon(
                          Icons.picture_as_pdf,
                          size: 40,
                          color: Colors.blue,
                        ),
                        FaIcon(
                          Icons.task_alt,
                          color: Colors.green,
                          size: widget.child.recibido == 'S' ? 30 : 0,
                        ),
                        FaIcon(
                          Icons.block,
                          color: Colors.red,
                          size: widget.child.recibido == 'S' ? 0 : 30,
                        ),
                      ],
                    )),
                const VerticalDivider(
                  color: Colors.white,
                  thickness: 2,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Empresa',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Text(
                      widget.child.empresa,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Text(
                      'Tipo documento',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Flexible(
                      child: Text(
                        widget.child.nombreDocumento,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const Text(
                      'Periodo',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Text(
                      widget.child.periodo,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String? path;
  final File? fileCreado;
  String nombre = '';
  String periodo = '';

  PDFScreen(
      {Key? key,
      required this.path,
      required this.fileCreado,
      required this.nombre,
      required this.periodo})
      : super(key: key);

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 1;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nombre} - ${widget.periodo}',
            style: const TextStyle(fontSize: 14)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final status = await Permission.storage.request();
              //print(status);
              if (!status.isGranted) {
                return;
              }
              Directory? downloadsDirectory =
                  await DownloadsPath.downloadsDirectory();
              String? downloadsDirectoryPath =
                  (await DownloadsPath.downloadsDirectory())?.path;
              File? fileCopiado = widget.fileCreado?.copySync(
                  '${downloadsDirectoryPath!}/BOLETA-${widget.periodo}.pdf');
              Fluttertoast.showToast(
                  msg: 'Su Boleta de Pago se guardo en su carpeta de Descargas',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.WIDTH,
            preventLinkNavigation: false,
            // if set to true the link is handled in flutter
            onRender: (pages) {
              setState(() {
                pages = pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {},
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }
}
