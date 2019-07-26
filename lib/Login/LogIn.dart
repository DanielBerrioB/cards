import "package:flutter/material.dart";
import "package:flutter_app/listPage/animatedList.dart";
import "SignUp.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:flutter_app/services/graphQLConf.dart";
import "package:shared_preferences/shared_preferences.dart";

class LogIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LogIn();
}

class _LogIn extends State<LogIn> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController txtUser = new TextEditingController();
  TextEditingController txtPassword = new TextEditingController();
  GraphQlObject graphQlObject = new GraphQlObject();
  int state = 0;
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
      ..then((prefs) {
        setState(() {
          this._prefs = prefs;
        });
      });
  }

  String userQuery() {
    return """ {
      user(email: "${txtUser.text.trim()}", password: "${txtPassword.text}"){
        name
      }
    } """;
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyButton() {
      if (state == 0) {
        return Text(
          ' Ingresar ',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        );
      } else {
        if (state == 1) {
          return SizedBox(
            width: 26.0,
            height: 26.0,
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        } else {
          return Icon(
            Icons.check,
            color: Colors.white,
          );
        }
      }
    }

    Future<Null> _setUserString(String email) async {
      await this._prefs.setString("userEmail", email);
    }

    InkWell buttonLogIn() {
      return InkWell(
        key: Key("logIn"),
        onTap: () async {
          if (txtPassword.text.isEmpty || txtUser.text.trim().isEmpty) {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text("Los campos estan incompletos"),
                duration: Duration(seconds: 4),
              ),
            );
          } else {
            setState(() {
              state = 1;
            });
            final GraphQLClient _client = graphQlObject.clientToQuery();
            final QueryResult result =
                await _client.query(QueryOptions(document: userQuery()));
            if (result.hasErrors && result.data != null) {
              setState(() {
                state = 0;
              });
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("Ha ocurrido un error revisa bien tus datos"),
                  duration: Duration(seconds: 4),
                ),
              );
            } else {
              if (result.data["user"] == null) {
                setState(() {
                  state = 0;
                });
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("No te encuentras registrado"),
                  duration: Duration(seconds: 4),
                ));
              } else {
                setState(() {
                  state = 2;
                });
                _setUserString(txtUser.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimatedListExample(
                          email: txtUser.text,
                        ),
                  ),
                );
              }
            }
          }
        },
        splashColor: Colors.amberAccent,
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: new BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: new BorderRadius.circular(10.0),
          ),
          child: bodyButton(),
        ),
      );
    }

    InkWell buttonSignUp() {
      return InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUp()));
        },
        child: Container(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'No tienes cuenta/Crea una aquí',
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
      );
    }

    Future<bool> _backBlock(context) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Quieres salir de la app"),
              actions: <Widget>[
                FlatButton(
                  child: Text("No"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("Si"),
                  onPressed: () => Navigator.pop(context, true),
                )
              ],
            ),
      );
    }

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        child: new Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 1.0,
            title: Text("Time"),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.announcement),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Información"),
                          content: Text(
                            "En esta ventana podrás iniciar sesión para entrar" +
                                " en la app y de esta forma disfrutar del contenido de esta.",
                            style: TextStyle(),
                          ),
                          actions: <Widget>[
                            new FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Cerrar"),
                            )
                          ],
                        );
                      });
                },
                tooltip: 'Información',
              ),
            ],
          ),
          body: Container(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: new Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16.0),
                      height: 120.0,
                      child: Center(
                        child: Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 10,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 18.0,
                        right: 18.0,
                        top: MediaQuery.of(context).size.height / 3 - 40,
                      ),
                      child: TextField(
                        key: Key("email"),
                        maxLength: 40,
                        controller: txtUser,
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: "Ingrese su email*",
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 18.0,
                        right: 18.0,
                        top: MediaQuery.of(context).size.height / 3 + 60,
                      ),
                      child: TextField(
                        key: Key("password"),
                        maxLength: 40,
                        obscureText: true,
                        controller: txtPassword,
                        decoration: InputDecoration(
                          icon: Icon(Icons.security),
                          labelText: "Ingrese su contraseña*",
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 3 + 170,
                      ),
                      child: Center(
                        child: buttonLogIn(),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 3 + 220,
                      ),
                      child: Center(
                        child: buttonSignUp(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: () => _backBlock(context),
      ),
    );
  }
}
