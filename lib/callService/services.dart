import 'package:intl/intl.dart';

class Respuesta {
  final bool success;
  final String message;
  final dynamic resultado;

  Respuesta({required this.success, required this.message, required this.resultado});

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(
        success: json['success'],
        message: json['message'],
        resultado: json['resultado']
    );
  }
}

class Aplicacion{
  final double num_version;
  final String nombre_version;
  final String fecha_pub;
  final String estado;

  Aplicacion({
    required this.num_version,
    required this.nombre_version,
    required this.fecha_pub,
    required this.estado
  });

  factory Aplicacion.fromJson(Map<String, dynamic> json){
    //print(json);
    return Aplicacion(
        num_version: json['num_version'] as double,
        nombre_version: json['nombre_version'] as String,
        fecha_pub: DateFormat('d/MM/y').add_jm().format(
           DateTime.parse(json['fecha_pub'])).toString(),
        estado: json['estado'] as String
    );
  }
}

class Notificacion {
  final int idNotificacion;
  final String titulo;
  final String descripcion;
  final String importancia;
  final String link;
  final String fechaPublicacion;
  final int diasPublicacion;
  final String estado;

  Notificacion({
    required this.idNotificacion,
    required this.titulo,
    required this.descripcion,
    required this.importancia,
    required this.link,
    required this.fechaPublicacion,
    required this.diasPublicacion,
    required this.estado
  });

  factory Notificacion.fromJson(Map<String, dynamic> json){
    return Notificacion(
        idNotificacion: json['idNotificacion'] as int,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String,
        importancia: json['importancia'] as String,
        link: json['link'] as String,
        fechaPublicacion: DateFormat('d/MM/y').add_jm().format(DateTime.parse(json['fechaPublicacion'])).toString(),
        diasPublicacion: json['diasPublicacion'] as int,
        estado: json['estado'] as String
    );
  }
}

class Documento{
  final int idDocumento;
  final String tipoDocumento;
  final String numeroDocumento;
  final String nombreDocumento;
  final String periodo;
  final String empresa;
  String recibido;
  final int periodoNum;
  final String fechaRecepcion;
  final String contenido;

  Documento({
    required this.idDocumento,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.nombreDocumento,
    required this.periodo,
    required this.empresa,
    required this.recibido,
    required this.periodoNum,
    required this.fechaRecepcion,
    required this.contenido
  });

  factory Documento.fromJson(Map<String, dynamic> json){
    return Documento(
        idDocumento: json['idDocumento'] as int,
        tipoDocumento: json['tipoDocumento'] as String,
        numeroDocumento: json['numeroDocumento'] as String,
        nombreDocumento: json['nombreDocumento'] as String,
        periodo: json['periodo'] as String,
        empresa: json['empresa'] as String,
        recibido: json['recibido'] as String,
        periodoNum: json['periodoNum'] as int,
        fechaRecepcion: json['fechaRecepcion'] as String,
        contenido: json['contenido'] as String
    );
  }
}
