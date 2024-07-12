import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:onlinestore/provider/cart.dart';
import 'package:onlinestore/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Mycart extends StatefulWidget {
  const Mycart({Key? key}) : super(key: key);

  @override
  State<Mycart> createState() => _MycartState();
}

class _MycartState extends State<Mycart> {
  late Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('userToken');

    setState(() {});
  }
  // String createCartMutation = '''
  //   mutation {
  //     createEmptyCart
  //   }
  // ''';

  String fatchcartdetails(String cartid) {
    Box box = Hive.box('userToken');
    String token = box.get('token') as String;
    var carttoken = box.get('cartToken');
    print(carttoken);
    return '''
{
  cart(cart_id: "$carttoken") {
    email
    billing_address {
      city
      country {
        code
        label
      }
      firstname
      lastname
      postcode
      region {
        code
        label
      }
      street
      telephone
    }
  
    items {
      id
      product {
        name
        sku
        
      }
      quantity
    }     
    available_payment_methods {
      code
      title
    }

    applied_coupons {
      code
    }
    prices {
      grand_total {
        value
        currency
      }
    }
  }
}

''';
  }

  Future<Map<String, dynamic>> productdetailshttp(sku) async {
    Box box = Hive.box('userToken');
    String token = box.get('token') as String;
    var rdata = await http.post(
      Uri.parse('https://wecancustomize.com/graphql/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'query': '''
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
        ''',
      }),
    );
    // rdata = jsonDecode(rdata.body);

    // print(rdata.body);
    // print(jsonDecode(rdata.body)['data']);
    Map<String, dynamic> data = jsonDecode(rdata.body);
    return data;
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

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);
    if (box.get('token') == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cart'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset('assets/cart.json', width: 400),
              Text('Missing Cart items?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/login',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Cart'),
        ),
        body: Query(
          options: QueryOptions(
            document: gql(
                fatchcartdetails(box.get('cartToken').toString() as String)),
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (result.hasException) {
              return Center(
                child: Text(result.exception.toString()),
              );
            }
            var cartdata = result.data!['cart'];

            var isLoading;
            return Stack(children: [
              Container(
                  child: ListView.builder(
                scrollDirection: Axis.vertical,
                // clipBehavior: Clip.none,
                itemCount: cartdata['items'].length,
                itemBuilder: (context, index) {
                  final cartitem = cartdata['items'][index];
                  final cartitemprice = cartdata['items'][index];
                  final productname = cartitem['product']['name'];
                  final productsku = cartitem['product']['sku'];
                  ;
                  final productquentity = cartitem['quantity'].toString();
                  var datax;
                  void getproductdetails() async {
                    datax = await productdetails(
                        productsku.toString().split('-')[0]);
                    // print(data);
                    print(
                        datax['data']['products']?['items'][0]['image']['url']);
                  }

                  // getproductdetails();
                  // var productimage =
                  //     (datax?['data']['products']?['items'][0]['image']['url']);

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          child: Query(
                              options: QueryOptions(
                                  document: gql(productdetails(
                                      productsku.toString().split('-')[0]))),
                              builder: (result, {fetchMore, refetch}) {
                                if (result.isLoading) {
                                  return CircularProgressIndicator();
                                }
                                if (result.hasException) {
                                  return Text(result.exception.toString());
                                }
                                // final product =
                                //     result.data?['products']?['items']?[0];
                                // String imageurl = product['image']['url'];
                                return Container();

                                // return Image.network(
                                //   imageurl,
                                //   width: 100,
                                //   height: 100,
                                // );
                              }),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productname,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  productsku,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Quantity: $productquentity',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Price: ${cartitemprice['price']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 70,
                  color: Colors.white,
                  // padding: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text('Cart Subtotal : '),
                              Text(
                                cartdata['prices']['grand_total']['value']
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue, // Set the button's background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/checkout');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
              ),
            ]);
          },
        ));
  }
}
