import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

// Future<ValueNotifier<GraphQLClient>> initializeGraphQLClient(
//     String yourGraphQLServerURL) async {
//   var access = await Hive.box('userToken').get('token') ?? '';

//   HttpLink httpLink = HttpLink(yourGraphQLServerURL, defaultHeaders: {
//     'Authorization': 'Bearer $access',
//   });

//   final ValueNotifier<GraphQLClient> client = ValueNotifier(
//     GraphQLClient(
//       cache: GraphQLCache(store: InMemoryStore()),
//       link: httpLink,
//     ),
//   );

//   return client;
// }

class GraphQLService {
  ValueNotifier<GraphQLClient> clientNotifier;

  GraphQLService(String yourGraphQLServerURL, String? token)
      : clientNotifier = ValueNotifier<GraphQLClient>(
          GraphQLClient(
            cache: GraphQLCache(store: InMemoryStore()),
            link: HttpLink(yourGraphQLServerURL),
          ),
        ) {
    initializeGraphQLClient(yourGraphQLServerURL, token ?? '');
  }

  Future<void> initializeGraphQLClient(
      String yourGraphQLServerURL, String token) async {
    String access = await Hive.box('userToken').get('token') ?? '';

    HttpLink httpLink = HttpLink(yourGraphQLServerURL, defaultHeaders: {
      'Authorization': 'Bearer $access',
    });

    clientNotifier.value = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    );
  }

  Future<void> reinitializeClient(
      String yourGraphQLServerURL, String token) async {
    await initializeGraphQLClient(yourGraphQLServerURL, token);
  }
}
