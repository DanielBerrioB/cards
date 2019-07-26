import "package:flutter/material.dart";
import 'package:flutter_app/Login/LogIn.dart';
import "package:flutter_app/listPage/listModel.dart";
import "package:flutter_app/listPage/simpleCard.dart";
import "package:flutter_app/services/graphQLConf.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";
import "alertDialog.dart";

class AnimatedListExample extends StatefulWidget {
  final String email;

  AnimatedListExample({Key key, this.email}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedList(this.email);
}

class _AnimatedList extends State<AnimatedListExample> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  ListModel<InsideItemCard> _list;
  InsideItemCard _selectedItem;
  TextEditingController txt1 = new TextEditingController();
  TextEditingController txt2 = new TextEditingController();
  TextEditingController txt3 = new TextEditingController();
  TextEditingController txt4 = new TextEditingController();
  GraphQlObject graphQlObject = new GraphQlObject();
  SharedPreferences _prefs;
  String dateEdit = "", emailUser;

  _AnimatedList(this.emailUser);

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
      ..then((prefs) {
        setState(() {
          this._prefs = prefs;
        });
      });
    _list = ListModel<InsideItemCard>(
      listKey: _listKey,
      initialItems: [],
      removedItemBuilder: _buildRemovedItem,
    );
    getAllCardByUser();
  }

  void getAllCardByUser() async {
    String userQuery = """{
        schedule(email: "$emailUser"){
          message
          date
          hour
        }
      } """;
    final GraphQLClient _client = graphQlObject.clientToQuery();
    final QueryResult result =
        await _client.query(QueryOptions(document: userQuery));
    if (result.hasErrors && result.data != null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No se cargaron los datos del usuario"),
        duration: Duration(seconds: 4),
      ));
    } else {
      if (result.data["schedule"] != null) {
        for (var i = 0; i < result.data["schedule"].length; i++) {
          _list.insert(
              i,
              InsideItemCard(
                  result.data["schedule"][i]["date"],
                  result.data["schedule"][i]["hour"],
                  result.data["schedule"][i]["message"]));
        }
      }
    }
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      element: _list[index],
      index: index,
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  Widget _buildRemovedItem(
      InsideItemCard item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      selected: false,
      index: _list.indexOf(item),
      element: item,
    );
  }

  String createMutation() {
    return """mutation {
      addSchedule(email: "${this._prefs.getString("userEmail")}", date: "${txt4.text}",
       hour: "${txt3.text}", message: "${txt1.text}"){
                    date
                    hour
                    message
           }
        }
    """;
  }

  // Insert the "next item" into the list model.
  void _insert() async {
    if (txt1.text.isEmpty || txt3.text.isEmpty || txt4.text.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No has ingresado todos los campos"),
        duration: Duration(seconds: 4),
      ));
    } else {
      int index =
          _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
      index = index == -1 ? 0 : index;
      final GraphQLClient _client = graphQlObject.clientToQuery();
      final QueryResult result =
          await _client.mutate(MutationOptions(document: createMutation()));

      if (!result.hasErrors) {
        _list.insert(index, InsideItemCard(txt4.text, txt3.text, txt1.text));
        setState(() {
          txt1.clear();
          txt2.clear();
          txt3.clear();
          txt4.clear();
        });
      }
    }
  }

  void _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2050));
    if (picked != null)
      setState(
          () => txt4.text = "${picked.month}/${picked.day}/${picked.year}");
  }

  void _selectHour(BuildContext context) async {
    TimeOfDay picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null)
      setState(() => txt3.text = "${picked.hour}:${picked.minute}");
  }

  // Remove the selected item from the list model.
  void _remove() async {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem));
      final GraphQLClient _client = graphQlObject.clientToQuery();
      final QueryResult result =
          await _client.mutate(MutationOptions(document: """ mutation{
            deleteSchedule(email:"${this._prefs.getString("userEmail")}", 
            date: "${_selectedItem.date}",
            hour: "${_selectedItem.hour}", message: "${_selectedItem.text}"){
              date
            }
          }"""));
      if (result.hasErrors) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("No se cargaron los datos del usuario"),
          duration: Duration(seconds: 4),
        ));
      } else {
        setState(() {
          _selectedItem = null;
        });
      }
    }
  }

  void _edit(context) {
    if (_selectedItem != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            AlertDialogWindow alert = AlertDialogWindow(
              email: this._prefs.getString("userEmail"),
              card: _selectedItem,
            );
            return alert;
          }).whenComplete(() {
        int size = _list.length;
        for (var j = 0; j < size; j++) {
          _list.removeAt(0);
        }
        getAllCardByUser();
      });
    }
  }

  void leavePage(context) {
    _prefs.setString("userEmail", "");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogIn()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Lista animada'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _edit(context),
              tooltip: 'Edit this element',
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _insert,
              tooltip: 'Insert a new item',
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: _remove,
              tooltip: 'Remove a selected item',
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () => leavePage(context),
              tooltip: "Leave the page",
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 18.0),
              child: Container(
                child: Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              right: 5.0,
                              left: MediaQuery.of(context).size.width / 10),
                          width: MediaQuery.of(context).size.width / 2 + 10,
                          child: RaisedButton.icon(
                            onPressed: () => _selectDate(context),
                            color: Colors.white,
                            splashColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.0)),
                            icon: Icon(Icons.calendar_today),
                            label:
                                Text(txt4.text.isEmpty ? "Fecha" : txt4.text),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width / 10),
                          width: MediaQuery.of(context).size.width / 2 - 10,
                          child: RaisedButton.icon(
                            onPressed: () => _selectHour(context),
                            color: Colors.white,
                            splashColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.0)),
                            icon: Icon(Icons.access_time),
                            label: Text(txt3.text.isEmpty ? "Hora" : txt3.text),
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 8,
                          right: MediaQuery.of(context).size.width / 8,
                          left: MediaQuery.of(context).size.width / 8),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Texto'),
                        style: TextStyle(fontSize: 18.0),
                        controller: txt1,
                        maxLength: 60,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: MediaQuery.of(context).size.height / 8 + 120),
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _list.length,
                itemBuilder: _buildItem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
