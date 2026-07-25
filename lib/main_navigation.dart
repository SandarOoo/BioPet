import 'package:flutter/material.dart';

// ============================================================
// IMPORT YOUR SCREENS
// ============================================================

import 'package:biopet/newfeed_screen.dart';

// Change this import if your actual file is different
import 'package:biopet/nearby_pets_map.dart';

// Change these imports to your actual AI screens
// import 'package:biopet/screens/ai/ai_chatbot_screen.dart';
// import 'package:biopet/screens/ai/classification_screen.dart';

// Change this to your actual shop screen
// import 'package:biopet/screens/shop/shop_screen.dart';


// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}


// ============================================================
// STATE
// ============================================================

class _MainNavigationState
    extends State<MainNavigation> {

  int _currentIndex = 0;


  // ==========================================================
  // PAGES
  // ==========================================================

  final List<Widget> _pages = [

    // 0
    const HomeScreen(),

    // 1
    const NearbyPetsMap(),

    // 2
    const AiChatbotPlaceholder(),

    // 3
    const ClassificationPlaceholder(),

    // 4
    const ShopPlaceholder(),
  ];


  // ==========================================================
  // NAVIGATION ITEM TAP
  // ==========================================================

  void _onItemTapped(
      int index,
      ) {

    setState(() {

      _currentIndex =
          index;

    });

  }


  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      // ======================================================
      // BODY
      // ======================================================

      body:

      IndexedStack(

        index:
        _currentIndex,

        children:
        _pages,

      ),


      // ======================================================
      // BOTTOM NAVIGATION BAR
      // ======================================================

      bottomNavigationBar:

      NavigationBar(

        selectedIndex:
        _currentIndex,

        onDestinationSelected:
        _onItemTapped,

        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        elevation:
        8,

        shadowColor:
        Colors.black12,

        indicatorColor:
        const Color(
          0xFFE8F5E9,
        ),

        labelBehavior:
        NavigationDestinationLabelBehavior
            .alwaysShow,

        destinations: [

          // ==================================================
          // NEWS FEED
          // ==================================================

          NavigationDestination(

            icon:

            const Icon(

              Icons
                  .dynamic_feed_outlined,

            ),

            selectedIcon:

            const Icon(

              Icons
                  .dynamic_feed,

            ),

            label:
            'Feed',

          ),


          // ==================================================
          // NEARBY
          // ==================================================

          NavigationDestination(

            icon:

            const Icon(

              Icons
                  .location_on_outlined,

            ),

            selectedIcon:

            const Icon(

              Icons
                  .location_on,

            ),

            label:
            'Nearby',

          ),


          // ==================================================
          // AI CHATBOT
          // ==================================================

          NavigationDestination(

            icon:

            const Icon(

              Icons
                  .smart_toy_outlined,

            ),

            selectedIcon:

            const Icon(

              Icons
                  .smart_toy,

            ),

            label:
            'AI Chat',

          ),


          // ==================================================
          // CLASSIFICATION
          // ==================================================

          NavigationDestination(

            icon:

            const Icon(

              Icons
                  .pets_outlined,

            ),

            selectedIcon:

            const Icon(

              Icons
                  .pets,

            ),

            label:
            'AI Scan',

          ),


          // ==================================================
          // SHOP
          // ==================================================

          NavigationDestination(

            icon:

            const Icon(

              Icons
                  .storefront_outlined,

            ),

            selectedIcon:

            const Icon(

              Icons
                  .storefront,

            ),

            label:
            'Shop',

          ),

        ],

      ),

    );

  }

}


// ============================================================
// AI CHATBOT PLACEHOLDER
// Replace this with your real AI Chatbot Screen
// ============================================================

class AiChatbotPlaceholder
    extends StatelessWidget {

  const AiChatbotPlaceholder({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar:

      AppBar(

        title:
        const Text(
          'AI Pet Assistant',
        ),

        centerTitle:
        true,

      ),

      body:

      const Center(

        child:

        Text(

          'AI Chatbot',

          style:

          TextStyle(

            fontSize:
            24,

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),

    );

  }

}


// ============================================================
// CLASSIFICATION PLACEHOLDER
// Replace this with your real Classification Screen
// ============================================================

class ClassificationPlaceholder
    extends StatelessWidget {

  const ClassificationPlaceholder({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar:

      AppBar(

        title:

        const Text(
          'Pet Breed Classification',
        ),

        centerTitle:
        true,

      ),

      body:

      const Center(

        child:

        Text(

          'AI Pet Classification',

          style:

          TextStyle(

            fontSize:
            24,

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),

    );

  }

}


// ============================================================
// SHOP PLACEHOLDER
// Replace this with your real Shop Screen
// ============================================================

class ShopPlaceholder
    extends StatelessWidget {

  const ShopPlaceholder({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar:

      AppBar(

        title:

        const Text(
          'BioPet Shop',
        ),

        centerTitle:
        true,

      ),

      body:

      const Center(

        child:

        Text(

          'Pet Shop',

          style:

          TextStyle(

            fontSize:
            24,

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),

    );

  }

}