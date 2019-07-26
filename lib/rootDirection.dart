import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_app/Login/LogIn.dart";
import "package:flutter_app/listPage/animatedList.dart";

class RootDirection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootDirection();
}

class _RootDirection extends State<RootDirection> {
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    try {
      SharedPreferences.getInstance()
        ..then((prefs) {
          setState(() {
            this._prefs = prefs;
          });
        });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (_prefs.getString("userEmail").isNotEmpty) {
        return AnimatedListExample(email: _prefs.get("userEmail"));
      }
      return LogIn();
    } catch (e) {
      return LogIn();
    }
  }
}
