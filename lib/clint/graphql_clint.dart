import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

Future<ValueNotifier<GraphQLClient>> initializeGraphQLClient(
    String yourGraphQLServerURL) async {
  String access = await Hive.box('userToken').get('token') ?? '';

  HttpLink httpLink = HttpLink(yourGraphQLServerURL, defaultHeaders: {
    'Authorization': 'Bearer $access',
  });

  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    ),
  );

  return client;
}
