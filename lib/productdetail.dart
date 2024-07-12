// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:onlinestore/provider/cart.dart';
import 'package:onlinestore/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  late String sku;
  int quantity = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    sku = widget.sku;
  }

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
            image {
              url
            }
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

  Future<void> additemtocart(
      String sku, int quantity, BuildContext context) async {
    Box box = Hive.box('userToken');
    String token = box.get('token') as String;
    var carttoken = box.get('cartToken');
    print(carttoken);
    var response = await http.post(
      Uri.parse('https://wecancustomize.com/graphql/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'query': '''
         mutation {
  addSimpleProductsToCart(
    input: {
      cart_id: "$carttoken",
      cart_items: [
        {
          data: {
            sku: "$sku",
            quantity: $quantity
          }
        }
      ]
    }
  ) {
    cart {
      items {
        id
        product {
          name
          sku
        }
        quantity
      }
    }
  }
}

        ''',
      }),
    );

    if (response.statusCode == 200) {
      var rdata = jsonDecode(response.body);
      print('Item added to cart');
      print(rdata);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added to cart'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print('Failed to add item to cart');
      print(response.body);
    }
    setState(() {
      isLoading = false;
    });
  }

  int colorindex = 0;
  int sizeindex = 0;
  String imageurl = '';

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);
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
                  onTap: () {
                    Navigator.pushNamed(context, '/cart');
                  },
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
      body: Query(
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
          if (imageurl == '') {
            imageurl = product['image']['url'];
          }
          double widthx = (MediaQuery.of(context).size.width * 0.8);
          var description = product['description']?['html'] as String? ?? '';
          description = description.replaceAll(RegExp(r'<[^>]*>'), '');

          if (product['configurable_options']?[1]?['values'] != null &&
              product['configurable_options'][1]['values'].isNotEmpty) {
            sizes = List<Map<String, dynamic>>.from(
                product['configurable_options'][1]['values']);
          } else {
            sizes = [];
          }
          print(sizes?.length);

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

          void changecolorindex(int index) {
            colorindex = index;
            color?[index]['label'];
            // sku = product['variants'][index]['product']['sku'];
            setState(() {
              // sku = product['variants'][index]['product']['sku'];
              imageurl = product['variants'][index]['product']['image']['url'];
              print(imageurl);
              sku =
                  '${widget.sku}-${sizes?[sizeindex]['label']}-${color?[colorindex]['label']}';
              print(sku);
            });
          }

          void changesizeindex(int indexsize) {
            sizeindex = indexsize;
            setState(() {
              sku =
                  '${widget.sku}-${sizes?[sizeindex]['label']}-${color?[colorindex]['label']}';
              print(sku);
            });
          }

          return Stack(children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Center(
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Image.network(
                              imageurl,
                              width: 200,
                              height: widthx,
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 15),
                      color != null && color!.isNotEmpty
                          ? Text(
                              'Color:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            )
                          : Container(),
                      rendercolor(
                        color: color ?? [],
                        changecolorindex: (int color) {
                          changecolorindex(color);
                          print(colorindex);
                        },
                      ),
                      // SizedBox(height: 10),
                      sizes != null && sizes!.isNotEmpty
                          ? Text(
                              'Size:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            )
                          : Container(),
                      sizes != null && sizes!.isNotEmpty
                          ? rendersize(
                              sizes: sizes!,
                              changesizeindex: (int size) {
                                changesizeindex(size);
                                print(size);
                              },
                            )
                          : Container(),

                      Text(
                        'Quentity:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.only(left: 10),
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 220, 216, 216)),
                            borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                });
                              },
                              child: Icon(Icons.remove),
                            ),
                            Text(
                              quantity.toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              child: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),
                      Text(
                        description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),

                      SizedBox(height: 50),
                      Row(
                        children: [],
                      )
                    ],
                  ),
                ),
              ),
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
                            setState(() {
                              isLoading = true;
                            });
                            // Add to cart logic
                            additemtocart(sku, quantity, context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Container(
                              child: Center(
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : Text('Add to Cart',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black)),
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
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class rendercolor extends StatefulWidget {
  final List<Map<String, dynamic>> color;
  // void changecolorindexvalue;

  var changecolorindex;

  rendercolor({super.key, required this.color, required this.changecolorindex});

  @override
  State<rendercolor> createState() => _rendercolorState();
}

class _rendercolorState extends State<rendercolor> {
  int selection = 0;
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
          return InkWell(
            onTap: () {
              widget.changecolorindex(index);
              // Add color selection logic
              setState(() {
                selection = index;
                print(selection);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(4),
                    border: selection == index
                        ? Border.all(color: Colors.black, width: 2)
                        : Border.all(color: Colors.grey, width: 1)),
                height: 40,
                width: 40,
              ),
            ),
          );
        },
      ),
    );
  }
}

class rendersize extends StatefulWidget {
  final List<Map<String, dynamic>> sizes;
  var changesizeindex;

  rendersize({super.key, required this.sizes, required this.changesizeindex});

  @override
  State<rendersize> createState() => _rendersizeState();
}

class _rendersizeState extends State<rendersize> {
  int selection = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.sizes.length,
        itemBuilder: (BuildContext context, int index) {
          var sizeval = widget.sizes[index]['label'];
          return InkWell(
            onTap: () {
              setState(() {
                selection = index;
              });
              widget.changesizeindex(index);
              // Add size selection logic
              print(sizeval);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                    border: selection == index
                        ? Border.all(color: Colors.black, width: 2)
                        : Border.all(color: Colors.grey, width: 1)),
                height: 40,
                width: 40,
                // color: Colors.grey[300],
                child: Center(
                  child: Text(sizeval ?? ''),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
