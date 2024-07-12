import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:onlinestore/accountpage.dart';
import 'package:onlinestore/catagorypage.dart';
import 'package:onlinestore/homepage.dart';
import 'package:onlinestore/mydrawer.dart';

class Myhomepage extends StatefulWidget {
  const Myhomepage({super.key});

  @override
  State<Myhomepage> createState() => _MyhomepageState();
}

class _MyhomepageState extends State<Myhomepage> {
  int _selectedIndex = 0; // Add this line

  // Define your pages here
  final List<Widget> _pages = [
    HomePage(), // Replace with your actual page
    Catagorypage(), // Replace with your actual page
    FavoritesPage(), // Replace with your actual page
    AccountPage(), // Replace with your actual page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Mydrawer(),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
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
      body: _pages.elementAt(_selectedIndex), // Update the body
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, // Add this line
        onTap: _onItemTapped, // Add this line
        key: const Key('bottomNavigationBar'),
      ),
    );
  }
}

// Placeholder widgets for your pages

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Favorites Page'));
}
