import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

class Productdetailpage extends StatefulWidget {
  final String sku;
  final String name;
  final String catagoery;

  Productdetailpage({
    super.key,
    required this.sku,
    required this.name,
    required this.catagoery,
  });

  @override
  State<Productdetailpage> createState() => _ProductdetailpageState();
}

class _ProductdetailpageState extends State<Productdetailpage> {
  List<Map<String, dynamic>>? color;
  List<Map<String, dynamic>>? sizes;

  String productdetails(String sku) {
    return '''
     {
  products(filter: { sku: { eq: "$sku" }}) {
    items {
      image {
        url
      }
      sku
      __typename
      price_range {
        minimum_price {
          final_price {
            currency
            value
          }
        }
      }
      description {
        html
      }
      ... on ConfigurableProduct {
        configurable_options {
          label
          values {
            label
          }
        }
        variants {
          product {
            sku
          }
          attributes {
            label
            code
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ecommerce Store'),
            Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.search),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.shopping_cart),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Query(
            options: QueryOptions(
              document: gql(productdetails(widget.sku)),
            ),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                return Center(child: Text(result.exception.toString()));
              }
              if (result.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              final product = result.data?['products']?['items']?[0];
              if (product == null) {
                return Center(child: Text('Product not found'));
              }

              double widthx = (MediaQuery.of(context).size.width * 0.8);
              var description =
                  product['description']?['html'] as String? ?? '';
              description = description.replaceAll(RegExp(r'<[^>]*>'), '');

              if (product['configurable_options']?[1]?['values'] != null &&
                  product['configurable_options'][1]['values'].isNotEmpty) {
                sizes = List<Map<String, dynamic>>.from(
                    product['configurable_options'][1]['values']);
              } else {
                sizes = [];
              }

              if (product['configurable_options']?[0]?['values'] != null &&
                  product['configurable_options'][0]['values'].isNotEmpty) {
                color = List<Map<String, dynamic>>.from(
                    product['configurable_options'][0]['values']);
              } else {
                color = [];
              }

              description = description
                  .replaceAll('&nbsp;', ' ')
                  .replaceAll('&bull', ' ')
                  .replaceAll(';', '')
                  .replaceAll('/', '');

              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: ListView(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        '${widget.name}',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '${widget.catagoery}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '£${product['price_range']['minimum_price']['final_price']['value']}',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      Card(
                        elevation: 5,
                        child: Image.network(
                          product['image']['url'],
                          width: 200,
                          height: widthx,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Color:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      rendercolor(color: color ?? []),
                      SizedBox(height: 10),
                      Text(
                        'Size:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      sizes != null && sizes!.isNotEmpty
                          ? rendersize(sizes: sizes!)
                          : Container(),
                      Text(
                        description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              // padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () {
                          // Add to cart logic
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Container(
                            child: Center(
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ),
                          ),
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set the button's background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        // Buy now logic
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Center(
                          child: Text('Buy Now',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class rendercolor extends StatefulWidget {
  final List<Map<String, dynamic>> color;

  rendercolor({super.key, required this.color});

  @override
  State<rendercolor> createState() => _rendercolorState();
}

class _rendercolorState extends State<rendercolor> {
  Color getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'purple':
        return Colors.purple;
      case 'gray':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.color.length,
        itemBuilder: (BuildContext context, int index) {
          var colorval = widget.color[index]['label'];
          Color containerColor = getColorFromName(colorval ?? '');
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              height: 40,
              width: 40,
            ),
          );
        },
      ),
    );
  }
}

class rendersize extends StatefulWidget {
  final List<Map<String, dynamic>> sizes;

  rendersize({super.key, required this.sizes});

  @override
  State<rendersize> createState() => _rendersizeState();
}

class _rendersizeState extends State<rendersize> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.sizes.length,
        itemBuilder: (BuildContext context, int index) {
          var sizeval = widget.sizes[index]['label'];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              width: 40,
              color: Colors.grey[300],
              child: Center(
                child: Text(sizeval ?? ''),
              ),
            ),
          );
        },
      ),
    );
  }
}
