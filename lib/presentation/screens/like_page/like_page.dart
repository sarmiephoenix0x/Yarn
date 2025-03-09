import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/like_page_controller.dart';

class LikePage extends StatefulWidget {
  final int selectedIndex;

  const LikePage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LikePageController(vsync: this),
      child: Consumer<LikePageController>(
          builder: (context, likePageController, child) {
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
                            "Bookmark",
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: likePageController.searchController,
                      focusNode: likePageController.searchFocusNode,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Search',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                            fontSize: 12.0,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.filter_list_alt),
                            onPressed: () {},
                          )),
                      cursorColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined,
                          size: 100, color: Colors.grey),
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
      }),
    );
  }
}
