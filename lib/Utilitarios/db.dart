import '../Modelo/Notif.dart';
import 'package:sqflite/sqflite.dart';

class DB{
  static Future<Database> _openDB()  async {
     String path = await getDatabasesPath();

     return openDatabase('$path/notificaciones.db',
        onCreate: (Database db,int version) async{
            await db.execute('CREATE TABLE notificacion(idNotificacion INTEGER PRIMARY KEY)');
        },
        version: 1,);

  }

  static Future<void> insert(Notif n) async{
    Database database = await _openDB();
    database.insert("notificacion", n.toMap());
  }

  static Future<List<Notif>> notificaciones(int idNotificacion) async{
    Database database = await _openDB();
    final List<Map<String, dynamic>> notificacionMap =
    await database.query("notificacion", where: "idNotificacion=?",
        whereArgs: [idNotificacion] );
    return List.generate(notificacionMap.length,
            (index) => Notif(
              idNotificacion: notificacionMap[index]["idNotificacion"]
            ));  }
}