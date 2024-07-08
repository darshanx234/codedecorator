import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Catagorypage extends StatefulWidget {
  const Catagorypage({super.key});

  @override
  State<Catagorypage> createState() => _CatagorypageState();
}

class _CatagorypageState extends State<Catagorypage> {
  int id = 1;
  String catagoryfatch() {
    return '''
     {
  category(id : 1) {
    products {
      total_count
      page_info {
        current_page
        page_size
        
      }
    }
    children_count
    children {
      id
      level
      name
      path
      
      children {
        id
        level
        name
        path
       
      }
    }
  }
}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
            // color: Colors.grey[200],
            width: 100,
            height: 800,
            // decoration: BoxDecoration(),
            child: Query(
              options: QueryOptions(
                document: gql(catagoryfatch()),
              ),
              builder: (QueryResult result,
                  {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.hasException) {
                  return Text(result.exception.toString());
                }

                if (result.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final List catagory =
                    result.data!['category']['children'][0]['children'] as List;
                return ListView.builder(
                  itemCount: catagory.length,
                  itemBuilder: (context, index) {
                    final catagoryy = catagory[index];
                    id = catagoryy['id'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          id = catagoryy['id'];
                        });
                      },
                      child: Container(
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                // Match the Card's borderRadius
                                child: Icon(Icons.category),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(catagoryy['name']),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )),
        Expanded(
          child: sidewidget(id: id),
        )
      ],
    );
  }
}

class sidewidget extends StatefulWidget {
  int id;
  sidewidget({super.key, required this.id});

  @override
  State<sidewidget> createState() => _sidewidgetState();
}

class _sidewidgetState extends State<sidewidget> {
  String catagoryfatch(id) {
    return '''
     {
  category(id: $id) {
    products {
      total_count
      page_info {
        current_page
        page_size
      }
    }
    children_count
    children {
      id
      level
      name
      path
      children {
        id
        level
        name
        path
        children {
          id
          level
          name
          path
          children {
            id
            level
            name
            path
          }
        }
      }
    }
  }
}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Container(
          height: 1000,
          color: Colors.grey[200],
          child: Query(
            options: QueryOptions(
              document: gql(catagoryfatch(widget.id)),
            ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (result.data!['category']['children'] == null) {
                return const Center(
                  child: Text('No data found'),
                );
              }

              final List catagory =
                  result.data!['category']['children'] as List;
              return ListView.builder(
                itemCount: catagory.length,
                itemBuilder: (context, index) {
                  final catagoryy = catagory[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        widget.id = catagoryy['id'];
                      });
                    },
                    child: Container(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              // Match the Card's borderRadius
                              child: Icon(Icons.category),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(catagoryy['name']),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )),
    ]);
  }
}
