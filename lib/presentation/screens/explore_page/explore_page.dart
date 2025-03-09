import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  final int selectedIndex;

  const ExplorePage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add Scaffold to each page
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Text(
                        "Explore",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 30.0,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No contents.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  // const SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: () => _fetchComments(),
                  // style: ElevatedButton.styleFrom(
                  //                   backgroundColor: Color(0xFF500450),
                  //                   shape: RoundedRectangleBorder(
                  //                     borderRadius: BorderRadius.circular(10),
                  //                   ),
                  //                 ),
                  //                 child: const Text(
                  //                   'Retry',
                  //                   style: TextStyle(color: Colors.white),
                  //                 ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
