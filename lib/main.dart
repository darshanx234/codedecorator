import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:onlinestore/cartpage.dart';
import 'package:onlinestore/clint/graphql_clint.dart';
import 'package:onlinestore/homepage.dart';
import 'package:onlinestore/loginpage.dart';
import 'package:onlinestore/myhomepage.dart';
import 'package:onlinestore/productdetail.dart';
import 'package:onlinestore/provider/cart_provider.dart';
import 'package:onlinestore/signuppage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await Hive.initFlutter(); // Await Hive initialization
  await Hive.openBox('userToken');
  await Hive.openBox('userDetails');

  final Future<ValueNotifier<GraphQLClient>> client =
      initializeGraphQLClient('https://wecancustomize.com/graphql/');

  // runApp(MyApp(client: await client));/

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MyApp(client: await client),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  const MyApp({required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ecommerce Store',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Myhomepage(),
          routes: {
            '/signup': (context) => Signuppage(),
            '/login': (context) => Loginpage(),
            '/home': (context) => Myhomepage(),
            '/cart': (context) => Mycart(),
          },
        ),
      ),
    );
  }
}
