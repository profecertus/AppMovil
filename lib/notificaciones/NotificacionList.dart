import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import '../callService/services.dart';

class NotificacionList extends StatefulWidget {
  final Notificacion child;

  const NotificacionList(this.child, {super.key});

  @override
  State<NotificacionList> createState() => _NotificacionList();
}

class _NotificacionList extends State<NotificacionList> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(children: <Widget>[
        Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 100 + (widget.child.descripcion.length~/40 + 1) * 50,
            width: MediaQuery.of(context).size.width * 0.94,
            //height: 80,
            //width: 80,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey, width: 1, style: BorderStyle.solid),
            ),
            //color: Colors.deepPurple[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const VerticalDivider(
                  color: Colors.white,
                  thickness: 2,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.child.titulo,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    SizedBox(
                      width: 300,
                      child:
                      Text(
                        widget.child.descripcion,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        softWrap: false,
                      ),
                    ),
                    const Text(
                      'Fecha Publicación',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Text(
                      widget.child.fechaPublicacion,
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

