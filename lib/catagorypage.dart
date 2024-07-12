import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:onlinestore/productpage.dart';

class Catagorypage extends StatefulWidget {
  const Catagorypage({super.key});

  @override
  State<Catagorypage> createState() => _CatagorypageState();
}

class _CatagorypageState extends State<Catagorypage> {
  int? id;
  int indexeq = 0;
  String catagoryfatch() {
    return '''
     {
  category(id : 2) {
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
    return Query(
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
//
        // if (result.data?['category']['children'] == null ||
        //     result.data?['category']['children'].isEmpty) {
        //   setState(() {
        //     id = result.data?['category']['children'][0]['id'] as int;
        //     print(id);
        //   });
        // }

        final List catagory = result.data!['category']['children'] as List;
        // setid(catagory[0]['id'] as int);
        // print(id);

        return Row(
          children: [
            Container(
              width: 100,
              height: 800,
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: catagory.length,
                itemBuilder: (context, index) {
                  final catagoryy = catagory[index];

                  return InkWell(
                    onTap: () {
                      setState(() {
                        id = catagoryy['id'];
                        indexeq = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            indexeq == index ? Colors.white : Colors.grey[200],
                        borderRadius: indexeq - 1 == index
                            ? BorderRadius.circular(20)
                            : BorderRadius.zero,
                      ),
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          Text(
                            catagoryy['name'],
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Divider(height: 1, color: Colors.grey[300])
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(child: SideWidget(id: id ?? catagory[0]['id'] as int)),
          ],
        );
      },
    );
  }
}

class SideWidget extends StatefulWidget {
  final int id;
  SideWidget({super.key, required this.id});

  @override
  State<SideWidget> createState() => _SideWidgetState();
}

class _SideWidgetState extends State<SideWidget> {
  String categoryFetch(int id) {
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
    return SingleChildScrollView(
      child: Container(
        height: 1000,
        // color: Colors.grey[200],
        child: Query(
          options: QueryOptions(
            document: gql(categoryFetch(widget.id)),
          ),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.hasException) {
              print(result.exception.toString());
              return Text(result.exception.toString());
            }

            if (result.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (result.data?['category']['children'] == null ||
                result.data?['category']['children'].isEmpty) {
              print('No data found');
              return Text('No data found');
            }

            final List category = result.data!['category']['children'] as List;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: category.length,
              itemBuilder: (context, index) {
                final categoryItem = category[index];
                return categoryItem['children'] != null &&
                        categoryItem['children'].isNotEmpty
                    ? ExpansionTile(
                        title: Text(categoryItem['name']),
                        leading: Icon(Icons.category),
                        children: categoryItem['children'].map<Widget>((child) {
                          return ListTile(
                            title: Text(child['name']),
                            leading: Icon(Icons.subdirectory_arrow_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsPage(
                                      categoryId: categoryItem['id'],
                                      catagoryname: categoryItem['name']),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsPage(
                                  categoryId: categoryItem['id'],
                                  catagoryname: categoryItem['name'],
                                ),
                              ),
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Icon(Icons.category),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(categoryItem['name']),
                            ],
                          ),
                        ),
                      );
              },
            );
          },
        ),
      ),
    );
  }
}
