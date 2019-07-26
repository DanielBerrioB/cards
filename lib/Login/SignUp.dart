import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:flutter_app/services/graphQLConf.dart";

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController txtUser = new TextEditingController();
  TextEditingController txtEmail = new TextEditingController();
  TextEditingController txtPassword = new TextEditingController();
  TextEditingController txtPasswordVerify = new TextEditingController();
  TextEditingController txtNameUser = new TextEditingController();
  GraphQlObject graphQlObject = new GraphQlObject();

  String createMutation() {
    return """mutation {
      addUser(email: "${txtEmail.text}", name: "${txtNameUser.text}", 
      userName: "${txtUser.text}", password: "${txtPassword.text}"){
                name
                userName
           }
        }
    """;
  }

  @override
  Widget build(BuildContext context) {
    InkWell buttonRegister() {
      return InkWell(
        onTap: () async {
          if (txtNameUser.text.trim().isEmpty ||
              txtEmail.text.trim().isEmpty ||
              txtUser.text.trim().isEmpty ||
              txtPassword.text.isEmpty ||
              txtPasswordVerify.text.isEmpty) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Atención"),
                    content: Text(
                      "Debes ingresar todos los campos requeridos",
                      style: TextStyle(),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Cerrar"))
                    ],
                  );
                });
          } else {
            if (txtPassword.text == txtPasswordVerify.text) {
              final GraphQLClient _client = graphQlObject.clientToQuery();
              final QueryResult result = await _client
                  .mutate(MutationOptions(document: createMutation()));

              if (result.hasErrors) {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(
                        "No se pudo registrar el usuario, revisa tu conexion"),
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                txtEmail.clear();
                txtPasswordVerify.clear();
                txtPassword.clear();
                txtUser.clear();
                txtNameUser.clear();
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text("Usuario registrado con exito"),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            } else {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("Las contrasenas no coinciden"),
                  duration: Duration(seconds: 3),
                ),
              );
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
          child: Text(
            ' Registrar ',
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      );
    }

    // TODO: implement build
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 1.0,
        title: Text("Registro"),
        actions: <Widget>[],
      ),
      body: new Container(
        child: new SingleChildScrollView(
          child: new ConstrainedBox(
            constraints:
                new BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Stack(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: MediaQuery.of(context).size.height / 3 - 160),
                  child: TextField(
                    maxLength: 20,
                    controller: txtUser,
                    decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: "Ingrese su nombre de usuario(Avatar)*"),
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: MediaQuery.of(context).size.height / 3 - 50),
                  child: TextField(
                    maxLength: 30,
                    controller: txtNameUser,
                    decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: "Ingrese su nombre*"),
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: MediaQuery.of(context).size.height / 3 + 60),
                  child: TextField(
                    maxLength: 30,
                    controller: txtEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: "Ingrese su email*"),
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: MediaQuery.of(context).size.height / 3 + 170),
                  child: TextField(
                    maxLength: 40,
                    controller: txtPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                        icon: Icon(Icons.security),
                        labelText: "Ingrese su contraseña*"),
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: MediaQuery.of(context).size.height / 3 + 270),
                  child: TextField(
                    maxLength: 40,
                    controller: txtPasswordVerify,
                    obscureText: true,
                    decoration: InputDecoration(
                        icon: Icon(Icons.security),
                        labelText: "Ingrese su contraseña de nuevo*"),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3 + 350,
                      bottom: 10.0),
                  child: Center(
                    child: buttonRegister(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
