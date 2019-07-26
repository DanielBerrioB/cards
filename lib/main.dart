import 'package:flutter/material.dart';
import "package:graphql_flutter/graphql_flutter.dart";
import "services/graphQLConf.dart";
import "rootDirection.dart";

GraphQlObject graphQlObject = new GraphQlObject();

void main() => runApp(
      GraphQLProvider(
        client: graphQlObject.client,
        child: CacheProvider(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MyApp(),
          ),
        ),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: RootDirection(),
    );
  }
}
