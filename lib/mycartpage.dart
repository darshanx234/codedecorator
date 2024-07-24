import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Mycartpage extends StatefulWidget {
  @override
  State<Mycartpage> createState() => _MycartpageState();
}

class _MycartpageState extends State<Mycartpage> {
  Future<Map<String, dynamic>> getUserData() async {
    var box = await Hive.box('userDetails');
    var box2 = await Hive.box('userToken');
    String? token = box2.get('cartToken');

    return {'token': token};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error loading user data')));
        }

        var userData = snapshot.data!;
        if (userData['token'] == null || userData['token'] == '') {
          return _buildLoginView(context);
        } else {
          return _buildLogoutView(context, userData['email']);
        }
      },
    );
  }

  Widget _buildLoginView(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No user logged in'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutView(BuildContext context, String? email) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome !', style: TextStyle(fontSize: 20)),
            Text('Email: $email'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                var box = await Hive.box('userDetails');
                var box2 = await Hive.box('userToken');
                await box.clear();
                await box2.clear();
                Navigator.pushNamed(context, '/home');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
