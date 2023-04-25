enum Servicios {
  getNotificaciones,
  getDocumentos,
  saveFirma,
  getPDF,
  olvidarPassword,
  cambiarPassword,
  validar,
  insertar,
  validaVer }

class Direcciones{
  final String protocolo = 'https://';
  final String dire = 'app.sunfruits.com.pe:9571/api';
  final String getNotificaciones = "/Notificacion/getNotificacionesActivas";
  final String getDocumentos = "/Documento/getDocumentos";
  final String saveFirma = "/Documento/saveFirma";
  final String getPDF = "/Documento/getPDF";
  final String olvidarPassword = "/Login/olvidarPassword";
  final String cambiarPassword = "/login/cambiarPassword";
  final String validar = "/login/validar";
  final String insertar = "/login/insertar";
  final String validaVer = "/Aplicacion/getLastVersion";

  String getUrlPrd(Servicios s){
    String direccion = "$protocolo$dire";
    String rpta = "";
    switch(s){
      case Servicios.validaVer:
          rpta = "$direccion$validaVer";
          break;
      case Servicios.getNotificaciones:
          rpta = "$direccion$getNotificaciones";
          break;
      case Servicios.getDocumentos:
          rpta = "$direccion$getDocumentos";
          break;
      case Servicios.saveFirma:
          rpta = "$direccion$saveFirma";
          break;
      case Servicios.getPDF:
          rpta = "$direccion$getPDF";
          break;
      case Servicios.olvidarPassword:
          rpta = "$direccion$olvidarPassword";
          break;
      case Servicios.cambiarPassword:
          rpta = "$direccion$cambiarPassword";
          break;
      case Servicios.validar:
          rpta = "$direccion$validar";
          break;
      case Servicios.insertar:
          rpta  = "$direccion$insertar";
          break;
      default:
          rpta = "";
        break;
    }
    return rpta;
  }
}