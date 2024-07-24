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
    // super.initState();
    box = Hive.box('userToken');

    // setState(() {});
  }
  // String createCartMutation = '''
  //   mutation {
  //     createEmptyCart
  //   }
  // ''';

  String fatchcartdetails(String cartid) {
    Box box = Hive.box('userToken');
    var token = box.get('token');
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
        thumbnail {
          url
        }
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
     
      discounts {
        amount {
          value
          currency
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

            return cartdata['items'].length == 0
                ? Emptycartpage()
                : Stack(children: [
                    Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              // clipBehavior: Clip.none,
                              itemCount: cartdata['items'].length,
                              itemBuilder: (context, index) {
                                final cartitem = cartdata['items'][index];
                                final cartitemprice = cartdata['items'][index];
                                final productname = cartitem['product']['name'];
                                final productsku = cartitem['product']['sku'];
                                final productimage =
                                    cartitem['product']['thumbnail']['url'];
                                // final productquentity = cartitem['quantity'].toString();
                                // final discount =
                                //     cartdata['prices']['discounts'][0]['amount']['value'];

                                // print('discount: $discount');

                                final productquentity =
                                    cartitem['quantity'].toString();
                                var datax;

                                // getproductdetails();
                                // var productimage =
                                //     (datax?['data']['products']?['items'][0]['image']['url']);

                                return Container(
                                  margin: EdgeInsets.all(10),
                                  child: Card(
                                    elevation: 4,
                                    child: Container(
                                      // width: MediaQuery.of(context).size.width * 0.9,
                                      // margin: EdgeInsets.all(10),
                                      // padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        // color: Color.fromARGB(255, 241, 247, 249),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 100,
                                            child: Image.network(productimage),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    productname,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    productsku,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Quantity: $productquentity',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Price: ${cartitemprice['price']}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 70),
                        ],
                      ),
                    ),
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

class Emptycartpage extends StatefulWidget {
  const Emptycartpage({super.key});

  @override
  State<Emptycartpage> createState() => _EmptycartpageState();
}

class _EmptycartpageState extends State<Emptycartpage> {
  @override
  Widget build(BuildContext context) {
    return Center(
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
                'Continue Shopping',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
