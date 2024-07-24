import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:onlinestore/clint/graphql_clint.dart';
import 'package:provider/provider.dart';

class Loginpage extends StatefulWidget {
  Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  void initState() {
    // Hive.box('userToken').clear();
    if (Hive.box('userToken').get('token') != null &&
        Hive.box('userToken').get('token') != '') {
      Navigator.pushNamed(context, '/home');
    }
    // TODO: implement initState
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  bool passwordVisible = false;
  bool isLoading = false;

  String loginMutation(String email, String password) {
    return '''
      mutation {
        generateCustomerToken(email: "${loginEmailController.text}", password: "${loginPasswordController.text}") {
          token
        }
      }
    ''';
  }

  Future<void> createcart(token) async {
    Box box = Hive.box('userToken');
    var rdata = await http.post(
      Uri.parse('https://wecancustomize.com/graphql/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'query': '''
          mutation {
            createEmptyCart
          }
        ''',
      }),
    );
    // rdata = jsonDecode(rdata.body);

    print(rdata.body);
    print(jsonDecode(rdata.body)['data']['createEmptyCart']);

    if (jsonDecode(rdata.body)['data']['createEmptyCart'] != null) {
      box.put('cartToken', jsonDecode(rdata.body)['data']['createEmptyCart']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            child: Column(
              children: [
                Center(
                  child: Image.network(
                    'https://wecancustomize.com/pub/media/logo/default/cd-logo_1.png',
                    height: 80,
                    width: 80,
                  ),
                ),
                Center(
                  child: Text('Welcome Back',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                ),
                Center(
                  child: Text('Login to your account',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey)),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: loginEmailController,
                    decoration: InputDecoration(
                        hintText: 'Enter Email',
                        labelText: "Email",
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.blue,
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    obscureText: !passwordVisible,
                    controller: loginPasswordController,
                    decoration: InputDecoration(
                        hintText: 'Enter Password',
                        labelText: "Password",
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          child: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.blue,
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blueGrey),
                          )),
                      SizedBox(width: 20)
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Mutation(
                  options: MutationOptions(
                    document: gql(loginMutation(
                      loginEmailController.text,
                      loginPasswordController.text,
                    )),
                    onCompleted: (dynamic resultData) async {
                      setState(() {
                        isLoading = false;
                      });
                      if (resultData != null) {
                        print(
                            'Login successful: ${resultData['generateCustomerToken']['token']}');
                        String token =
                            resultData['generateCustomerToken']['token'];
                        Hive.box('userToken').put('token', token);
                        Hive.box('userDetails')
                            .put('email', loginEmailController.text);
                        createcart(token);
                        // Reinitialize the GraphQL client with the new token
                        final graphqlservice =
                            Provider.of<GraphQLService>(context, listen: false);

                        // Assuming reinitializeClient is an async method, you should await it
                        await graphqlservice.reinitializeClient(
                            'https://wecancustomize.com/graphql/', token);

                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false);
                      }
                    },
                    onError: (error) {
                      setState(() {
                        isLoading = false;
                      });
                      print('Login failed: $error');
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult? result) {
                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                runMutation({});
                              }
                            },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100.0, vertical: 10.0),
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: 150,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('OR'),
                    ),
                    Container(
                      height: 1,
                      width: 150,
                      color: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Sign up',
                        style: TextStyle(color: Colors.blue, fontSize: 15),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
