import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Signuppage extends StatefulWidget {
  Signuppage({super.key});

  @override
  State<Signuppage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Signuppage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  TextEditingController loginFirstNameController = TextEditingController();
  TextEditingController loginLastNameController = TextEditingController();
  TextEditingController loginConfirmPasswordController =
      TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  String Signupmutation(
      String firstname, String lastname, String email, String password) {
    return '''
      mutation {
  createCustomer(
    input: {
      firstname: "$firstname"
      lastname: "$lastname"
      email: "$email"
      password: "$password"
      is_subscribed: true
    }
  ) {
    customer {
      firstname
      lastname
      email
    }
  }
}
    ''';
  }

  String loginMutation(String email, String password) {
    return '''
      mutation {
        generateCustomerToken(email: "$email", password: "$password") {
          token
        }
      }
    ''';
  }

  Future<void> _submit() async {
    Box box = Hive.box('userToken');
    var rdata = await http.post(
      Uri.parse('https://wecancustomize.com/graphql/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'query': loginMutation(
          loginEmailController.text,
          loginPasswordController.text,
        ),
      }),
    );
    jsonDecode(rdata.body);

    print(rdata.body);
    print(jsonDecode(rdata.body)['data']['generateCustomerToken']['token']);
    String token =
        jsonDecode(rdata.body)['data']['generateCustomerToken']['token'];

    if (jsonDecode(rdata.body)['data']['generateCustomerToken']['token'] !=
        null) {
      box.put('token', token);
      createcart(token);

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  Future<void> createcart(String token) async {
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
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
                  child: Text('Create Account',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                ),
                Center(
                  child: Text('Sign up to get started',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey)),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: loginFirstNameController,
                    decoration: InputDecoration(
                        hintText: 'Enter your first name',
                        labelText: "First Name",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blue,
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your first name';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: loginLastNameController,
                    decoration: InputDecoration(
                        hintText: 'Enter your last name',
                        labelText: "Last Name",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blue,
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your last name';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: loginEmailController,
                    decoration: InputDecoration(
                        hintText: 'Enter your email',
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
                SizedBox(height: 13),
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
                        return 'Password must be at least 8 characters long';
                      }

                      // Check for different classes of characters
                      bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
                      bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
                      bool hasDigits = value.contains(RegExp(r'[0-9]'));
                      bool hasSpecialCharacters =
                          value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

                      int classesCount = [
                        hasLowerCase,
                        hasUpperCase,
                        hasDigits,
                        hasSpecialCharacters
                      ].where((c) => c).length;

                      if (classesCount < 3) {
                        List<String> missingClasses = [];
                        if (!hasLowerCase)
                          missingClasses.add('lowercase letters');
                        if (!hasUpperCase)
                          missingClasses.add('uppercase letters');
                        if (!hasDigits) missingClasses.add('digits');
                        if (!hasSpecialCharacters)
                          missingClasses.add('special characters');

                        return 'add : ${missingClasses.join(', ')} in your password';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    obscureText: !passwordVisible,
                    controller: loginConfirmPasswordController,
                    decoration: InputDecoration(
                        hintText: 'Re-enter Password',
                        labelText: "Confirm Password",
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
                      if (value != loginPasswordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(height: 50),
                Mutation(
                  options: MutationOptions(
                    document: gql(Signupmutation(
                      loginFirstNameController.text,
                      loginLastNameController.text,
                      loginEmailController.text,
                      loginPasswordController.text,
                    )),
                    onCompleted: (dynamic resultData) {
                      setState(() {
                        isLoading = false;
                      });
                      if (resultData != null &&
                          resultData['createCustomer'] != null) {
                        print(resultData);
                        _submit();

                        Box box = Hive.box('userDetails');
                        box.put('firstname', loginFirstNameController.text);
                        box.put('lastname', loginLastNameController.text);
                        box.put('email', loginEmailController.text);
                      } else {
                        print('Login failed');
                      }
                    },
                    onError: (error) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${error?.graphqlErrors[0].message}'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 4),
                        ),
                      );

                      print('Error: ${error?.graphqlErrors[0].message}');
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
                                "Sign Up",
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
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Sign in',
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
