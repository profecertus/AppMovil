import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prueba_sun_fruits/login_page.dart';
import 'package:workmanager/workmanager.dart';
import 'Modelo/Notif.dart';
import 'Utilitarios/db.dart';
import 'callService/direcciones.dart';
import 'callService/services.dart';
import 'package:http/http.dart' as http;

Future<List<Notificacion>> getNotificaciones(http.Client client) async {
  var endpointUrl =
  Uri.parse(Direcciones().getUrlPrd(Servicios.getNotificaciones));
  final response = await client.get(endpointUrl);
  List<Notificacion> rpta = parseNotificacion(response.body);
  return rpta;
}

List<Notificacion> parseNotificacion(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<Notificacion>((json) => Notificacion.fromJson(json))
      .toList();
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    List<Notificacion> respuesta = await getNotificaciones(http.Client());

    for(Notificacion element in respuesta) {
      List<Notif> ln = await DB.notificaciones(element.idNotificacion);
      if( ln.isEmpty ){
        AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: element.idNotificacion,
              channelKey: 'basic_channel',
              title:element.titulo,
              body:element.descripcion,
            )
        );
        Notif n = Notif(idNotificacion: element.idNotificacion);
        DB.insert(n);
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Test de las Notificaciones',
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
  );
  Workmanager().cancelAll();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().registerPeriodicTask(
    'periodicalTaskKey',
    'taskPeriodical',
    initialDelay: const Duration(seconds: 10),
  );
  await FlutterDownloader.initialize();

  runApp(
    const ChatApp()
  );
}

class Palette {
  static const MaterialColor kToDark = MaterialColor(
    0xffe59752, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffe59752), //10%
      100: Color(0xffe19c76), //20%
      200: Color(0xffc5945c), //30%
      300: Color(0xffe3af85), //40%
      400: Color(0xffc0935f), //50%
      500: Color(0xff5c261d), //60%
      600: Color(0xff451c16), //70%
      700: Color(0xff2e130e), //80%
      800: Color(0xff170907), //90%
      900: Color(0xff000000), //100%
    },
  );
}

class ChatApp extends StatelessWidget {
  const ChatApp({
    super.key
  });

  @override
  StatelessElement createElement() {
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    });
    // TODO: implement build
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('es'),
        const Locale('en')
      ],
      debugShowCheckedModeBanner: false,
      title: 'eSun Movil',
      theme: ThemeData(
        primarySwatch: Palette.kToDark,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.purple[900], //<-- SEE HERE
          displayColor: Colors.black, //<-- SEE HERE
        ),
      ),
      //home:const ImageScreen(),
      home: const LoginPage(),
    );
  }
}

