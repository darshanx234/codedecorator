import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Mydrawer extends StatefulWidget {
  const Mydrawer({super.key});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  late Future<List<String>> footerItemsFuture;

  @override
  void initState() {
    super.initState();
    footerItemsFuture =
        fetchGraphQLData(); // Fetch data when the state is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 200,
            child: Center(
                child: Column(
              children: [
                Image.network(
                    'https://wecancustomize.com/pub/media/logo/default/cd-logo_1.png'),
                Text(
                  'Ecommerce Store',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            )),
          ),
          FutureBuilder<List<String>>(
            future: footerItemsFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                ); // Show loading indicator while waiting for data
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // Show error if any
              } else {
                // Build the list view when data is fetched
                return ListView.builder(
                  shrinkWrap:
                      true, // Use shrinkWrap to make ListView inside ListView work
                  physics:
                      NeverScrollableScrollPhysics(), // Disable scrolling for the inner ListView
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(snapshot.data![index]),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

Future<List<String>> fetchGraphQLData() async {
  List<String> fitem = [];
  const String url = 'https://wecancustomize.com/graphql/';
  const String query = '''
  {
    cmsBlocks(identifiers: "mobile-footer-link") {
      items {
        identifier
        title
        content
      }
    }
  }
  ''';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({'query': query}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    var val = data['data']['cmsBlocks']['items'][0]['content'];
    val = val.replaceAll('<p>', '').replaceAll('</p>', '');
    var d1 = jsonDecode(val.toString());
    d1.forEach((key, value) {
      fitem.add(key.toString());
    });
  } else {
    print('Failed to load data');
  }
  return fitem;
}
