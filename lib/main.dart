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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await Hive.initFlutter(); // Await Hive initialization
  await Hive.openBox('userToken');
  await Hive.openBox('userDetails');

  // final Future<ValueNotifier<GraphQLClient>> client =
  //     initializeGraphQLClient('https://wecancustomize.com/graphql/');

  // runApp(MyApp(client: await client));/
  final graphQLService =
      GraphQLService('https://wecancustomize.com/graphql/', '');

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MyApp(graphQLService: graphQLService),
    ),
  );
}

class MyApp extends StatefulWidget {
  // final ValueNotifier<GraphQLClient> client;
  final GraphQLService graphQLService;
  const MyApp({required this.graphQLService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> createcart() async {
    Box box = Hive.box('userToken');
    var rdata = await http.post(
      Uri.parse('https://wecancustomize.com/graphql/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'query': '''
          mutation {
            createEmptyCart
          }
        ''',
      }),
    );
    // rdata = jsonDecode(rdata.body);

    print(rdata.body);
    String carttoken = jsonDecode(rdata.body)['data']['createEmptyCart'];
    print(carttoken);

    if (carttoken != null) {
      box.put('cartToken', carttoken);
    }
  }

  @override
  void initState() {
    var box = Hive.box('userToken');

    if (box.get('cartToken') == null) {
      createcart();
    }
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GraphQLService>(
      create: (context) => widget.graphQLService,
      child: ValueListenableBuilder<GraphQLClient>(
        valueListenable: widget.graphQLService.clientNotifier,
        builder: (context, client, child) {
          return GraphQLProvider(
            client: ValueNotifier<GraphQLClient>(client),
            child: CacheProvider(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Ecommerce Store',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  useMaterial3: true,
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
        },
      ),
    );
  }
}
