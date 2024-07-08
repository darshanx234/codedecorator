import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String categoryFetch() {
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
    return ListView(
      children: [
        Container(
          height: 200,
          child: CarouselSlider(
            items: [
              Image.asset('assets/image.png'),
              Image.asset('assets/image2.png'),
              Image.asset('assets/image3.png'),
            ],
            options: CarouselOptions(
              height: 300,
              autoPlay: true, // Enabled autoPlay
              aspectRatio: 16 / 9,
              enlargeCenterPage: true,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('view all', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Container(
          height: 100, // Set a height for the container
          child: Query(
            options: QueryOptions(
              document: gql(categoryFetch()),
            ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Center(child: Text(result.exception.toString()));
              }

              if (result.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              // Handle the result data here
              List categories =
                  result.data?['category']['children'][0]['children'] as List;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
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
                        const SizedBox(height: 10),
                        Text(category['name']),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Hot Sellers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('view all', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Container(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10), // Match the Card's borderRadius
                        child: Image.asset(
                          'assets/image.png',
                          height: 100,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Product Name'),
                      const Text('\$100',
                          style: TextStyle(color: Colors.blue, fontSize: 17)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Hot Sellers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('view all', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Container(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10), // Match the Card's borderRadius
                        child: Image.asset(
                          'assets/image.png',
                          height: 100,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Product Name'),
                      const Text('\$100',
                          style: TextStyle(color: Colors.blue, fontSize: 17)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
