import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:onlinestore/productdetail.dart';

class ProductsPage extends StatelessWidget {
  final int categoryId;
  final String catagoryname;

  ProductsPage({
    required this.categoryId,
    required this.catagoryname,
  });

  @override
  Widget build(BuildContext context) {
    print(categoryId);
    return Scaffold(
      appBar: AppBar(
        title: Text('$catagoryname'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getProductsByCategoryQuery),
          variables: {
            'categoryId': categoryId.toString(),
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final products = result.data?['products']['items'] ?? [];

          // Get the screen width
          double screenWidth = MediaQuery.of(context).size.width;
          // Define the desired width of each item
          double itemWidth = 165.0;
          // Calculate the number of columns
          int crossAxisCount = (screenWidth / itemWidth).floor();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.820,
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final product = products[index];
              return Container(
                // color: Colors.yellow,
                margin: const EdgeInsets.only(left: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Productdetailpage(
                                  sku: product['sku'],
                                  name: product['name'],
                                  catagoery: catagoryname,
                                )));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ensure the image does not overflow
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: product['image']['url'],
                          width: (screenWidth / crossAxisCount) * 0.65,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      SizedBox(height: 8), // Add some spacing
                      // Wrap text widgets to prevent overflow
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          product['name'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow
                              .ellipsis, // Add ellipsis to handle overflow
                          maxLines: 1, // Limit to one line
                        ),
                      ),
                      SizedBox(height: 4), // Add some spacing
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          product['price_range']['minimum_price']['final_price']
                                  ['value']
                              .toString(),
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                          overflow: TextOverflow
                              .ellipsis, // Add ellipsis to handle overflow
                          maxLines: 1, // Limit to one line
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String get getProductsByCategoryQuery {
    return '''
      query GetProductsByCategory(\$categoryId: String) {
        products(filter: {
          category_id: {
            eq: \$categoryId
          }
        }) {
          items {
            name
            sku
            image {
              url
            }
            price_range {
              minimum_price {
                final_price {
                  currency
                  value
                }
              }
            }
          }
        }
      }
    ''';
  }
}
