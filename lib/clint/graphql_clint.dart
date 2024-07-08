import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> initializeGraphQLClient(
    String yourGraphQLServerURL) {
  final HttpLink httpLink = HttpLink(yourGraphQLServerURL);

  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    ),
  );

  return client;
}
