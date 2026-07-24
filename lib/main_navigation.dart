import 'package:biopet/nearby_pets_map.dart';
import 'package:flutter/material.dart';

import 'package:biopet/newfeed_screen.dart';
import 'package:biopet/map_screen.dart';
import 'package:biopet/pet_chat_screen.dart';
import 'package:biopet/views/home/home_page.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}


class _MainNavigationState extends State<MainNavigation> {

  int _currentIndex = 0;


  final List<Widget> _pages = const [

    // Feed
    HomeScreen(),

    // Map
    NearbyPetsMap(),

    // Chat
    PetChatScreen(),

    // Profile
    HomePage(),

  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),


      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _currentIndex,

        onTap: (index){

          setState(() {

            _currentIndex = index;

          });

        },


        type: BottomNavigationBarType.fixed,


        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: "Map",
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: "Chat",
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),

        ],

      ),

    );
  }
}