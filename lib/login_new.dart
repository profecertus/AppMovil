import 'dart:convert';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:prueba_sun_fruits/callService/direcciones.dart';
import 'package:prueba_sun_fruits/callService/services.dart';
import 'package:intl/intl.dart';

class LoginNew extends StatefulWidget {
  const LoginNew({Key? key}) : super(key: key);

  @override
  State<LoginNew> createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew> {
  final _textControllerDNI = TextEditingController();
  final _textControllerFE = TextEditingController();
  final _textControllerCorreo = TextEditingController();
  final _textControllerCelular = TextEditingController();
  final _textControllerPassword = TextEditingController();
  bool _isVisibleNew = false;
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();
  final format = DateFormat('dd/MM/yyyy');
  double _tamanno = 0.0;

  void showLoad(double valor){
    setState(() {
      _tamanno = valor;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          Form(
            key: _formKey,
            child:Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const [
                        Icon(Icons.sentiment_satisfied),
                        SizedBox(width: 10,),
                        Text('Registro de datos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                      ],
                    ),
                    const Text('Ingresa tus datos para validación:\n', style: TextStyle(fontSize: 20),),
                    TextFormField(
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Ingrese el numero de DNI';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(8),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      controller: _textControllerDNI,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'DNI',
                          suffixIcon: IconButton(onPressed: (){
                            _textControllerDNI.clear();
                          }, icon: const Icon(Icons.person))
                      ),
                    ),
                    DateTimeField(format: format,
                        controller: _textControllerFE,
                        decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: 'Fecha emisión DNI',
                            suffixIcon: IconButton(onPressed: (){},
                                icon: const Icon(Icons.calendar_today))
                        ),
                        onShowPicker:(context, currentValue) async{
                          final date = showDatePicker(context: context,
                              locale: const Locale("es","ES"),
                              initialDate: currentValue ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now());
                          return date;
                        }
                    ),
                    TextFormField(
                      validator: (value){
                        if(value == null || value.isEmpty
                            || !value.contains('@') || !value.contains('.')){
                          return 'Ingrese el correo electrónico';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: _textControllerCorreo,
                      maxLength: 100,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Correo electrónico',
                          suffixIcon: IconButton(onPressed: (){},
                              icon: const Icon(Icons.markunread))
                      ),
                    ),
                    TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(9),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Ingrese el número de celular';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      controller: _textControllerCelular,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Número celular',
                          suffixIcon: IconButton(onPressed: (){
                            _textControllerCelular.clear();
                          }, icon: const Icon(Icons.phone_android))
                      ),
                    ),
                    TextFormField(
                      validator: (value){
                        RegExp regex = RegExp(
                            //r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$');
                            r'^(?=.*?[A-Za-z0-9]).{6,}$');
                        if (value == null || value.isEmpty){
                          return 'Ingrese la contraseña';}
                        if (value.length < 6) {
                          return
                          'mínimo 6 caracteres máximo 10 caracteres';
                        }
                        if (!regex.hasMatch(value)) {
                          return
                          'Letras y números';
                        }
                        return null;
                      },
                      maxLength: 10,
                      obscureText: !_isVisibleNew,
                      controller: _textControllerPassword,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(onPressed: (){
                            setState(() {
                              _isVisibleNew = !_isVisibleNew;
                            });
                          },
                              icon: _isVisibleNew ?  const Icon(Icons.visibility) : const Icon(Icons.visibility_off))
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            value: _isChecked,
                            onChanged: (bool? value){
                              setState(() {
                                _isChecked = value!;
                              });
                            }
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: const Text('He leído y acepto los Términos y Condiciones y las Politicas de uso de datos personales', textAlign: TextAlign.justify,)),
                        const SizedBox(height: 15,),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar', style: TextStyle(fontSize: 20),),
                        ),
                        FilledButton(
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              if(_isChecked) {
                                /***API Put  ***/
                                var body = jsonEncode({
                                  'tipoDocumento' : 'DNI',
                                  'numDocumento' : _textControllerDNI.text,
                                  'email': _textControllerCorreo.text,
                                  'numCelular': _textControllerCelular.text,
                                  'contrasenna':_textControllerPassword.text,
                                  'fechaEmision': _textControllerFE.text
                                });

                                var endpointUrl = Uri.parse(Direcciones().getUrlPrd(Servicios.insertar));
                                Future<Respuesta> fetchPut() async{
                                  final response =
                                  await http.put(endpointUrl, body:body, headers: {
                                    "Accept":"application/json",
                                    "content-type":"application/json"
                                  });
                                  if (response.statusCode == 200) {
                                    // Si el servidor devuelve una repuesta OK, parseamos el JSON
                                    return Respuesta.fromJson(json.decode(response.body));
                                  } else {
                                    // Si esta respuesta no fue OK, lanza un error.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text(
                                          'Error al momento de guardar la información')),
                                    );
                                    throw Exception('Fallo al llamar al servicio - ${response.statusCode}${response.body}');
                                  }
                                }
                                showLoad(MediaQuery.of(context).size.height);
                                final Respuesta respuesta = await fetchPut();
                                showLoad(0);
                                if(respuesta.success){
                                  Fluttertoast.showToast(
                                      msg: 'Se enviará un correo con las indicaciones',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                                Navigator.pop(context);
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(
                                      'Debe Aceptar las Condiciones')),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Enviar',
                            style: TextStyle(fontSize: 20, ),),
                        ),
                      ],
                    ),
                  ],
                ), ),

            ), ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: _tamanno,
            color: Colors.grey.withOpacity(0.7),
            child:Column(
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
                const Text('Enviando su información', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),)
              ],
            )
          ),
        ],
      ),
    );
  }
}
