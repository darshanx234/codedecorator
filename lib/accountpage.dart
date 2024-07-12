import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Box box;
  late Box box2;

  @override
  void initState() {
    super.initState();
    box = Hive.box('userDetails');
    box2 = Hive.box('userToken');
  }

  @override
  Widget build(BuildContext context) {
    if (box.values.isEmpty) {
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
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome !', style: TextStyle(fontSize: 20)),
              Text('Email: ${box.get('email')}'),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () async {
                  await box.clear();
                  await box.clear();
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
}
