class Notif{
    int idNotificacion;

    Notif({required this.idNotificacion});

    Map<String, dynamic> toMap(){
      return {'idNotificacion': idNotificacion};
    }
}