import "package:flutter/material.dart";
import "package:flutter_app/services/graphQLConf.dart";
import "package:graphql_flutter/graphql_flutter.dart";

import "simpleCard.dart";

class AlertDialogWindow extends StatefulWidget {
  final String email;
  final InsideItemCard card;

  AlertDialogWindow({Key key, this.email, this.card}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _AlertDialogWindow(this.email, this.card);
}

class _AlertDialogWindow extends State<AlertDialogWindow> {
  String txtDate = "", txtHour = "", userEmail;
  TextEditingController txtEdit = TextEditingController();
  GraphQlObject graphQlObject = new GraphQlObject();
  InsideItemCard card;

  _AlertDialogWindow(this.userEmail, this.card);

  String editMutation() {
    return """mutation{
      editSchedule(email:"$userEmail", 
      date: "${card.date}", hour: "${card.hour}", message: "${card.text}",
       newDate: "$txtDate", newHour: "$txtHour", newMessage: "${txtEdit.text}"){
        date
        hour
      }
    }""";
  }

  void _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2050));
    if (picked != null)
      setState(() => txtDate = "${picked.month}/${picked.day}/${picked.year}");
  }

  void _selectHour(BuildContext context) async {
    TimeOfDay picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null)
      setState(() => txtHour = "${picked.hour}:${picked.minute}");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      content: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(right: 20.0),
                  child: RaisedButton.icon(
                      color: Colors.white,
                      splashColor: Colors.red,
                      onPressed: () => _selectDate(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0)),
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        txtDate.isEmpty ? "Fecha" : txtDate,
                        style: TextStyle(fontSize: 11.5),
                      ))),
              Container(
                  child: RaisedButton.icon(
                      color: Colors.white,
                      splashColor: Colors.red,
                      onPressed: () => _selectHour(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0)),
                      icon: Icon(Icons.access_time),
                      label: Text(
                        txtHour.isEmpty ? "Hora" : txtHour,
                        style: TextStyle(fontSize: 11.5),
                      ))),
            ],
          ),
          Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 8),
              child: TextField(
                maxLength: 40,
                controller: txtEdit,
                decoration: InputDecoration(
                    icon: Icon(Icons.edit), labelText: "Editar"),
              )),
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cerrar")),
        FlatButton(
          onPressed: () async {
            if (txtEdit.text.trim().isNotEmpty &&
                txtDate.isNotEmpty &&
                txtHour.isNotEmpty) {
              final GraphQLClient _client = graphQlObject.clientToQuery();
              final QueryResult result = await _client
                  .mutate(MutationOptions(document: editMutation()));
              if (!result.hasErrors) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Text("Editar"),
        )
      ],
    );
  }
}
