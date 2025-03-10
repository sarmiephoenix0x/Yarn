import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/location_widget.dart';
import '../../../core/widgets/tab.dart';
import '../../controllers/search_page_controller.dart';
import 'widgets/page_widget.dart';

class SearchPage extends StatefulWidget {
  final int selectedIndex;

  const SearchPage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchPageController(vsync: this),
      child: Consumer<SearchPageController>(
          builder: (context, searchPageController, child) {
        return Scaffold(
          // Add Scaffold to each page
          body: ListView(
            children: [
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: searchPageController.searchController,
                      focusNode: searchPageController.searchFocusNode,
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
                            icon: const Icon(Icons.close_outlined),
                            onPressed: () {
                              searchPageController.searchController.clear();
                              searchPageController.searchLocations('');
                            },
                          )),
                      cursorColor: Theme.of(context).colorScheme.onSurface,
                      onChanged: (value) {
                        searchPageController.searchLocations(value);
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  TabBar(
                    controller: searchPageController.explorerTabController,
                    tabs: [
                      TabWidget(name: 'Locations'),
                      TabWidget(name: 'Topics'),
                      TabWidget(name: 'Author'),
                    ],
                    //tabNames.map((name) => _buildTab(name)).toList(),
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    labelPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
                      controller: searchPageController.explorerTabController,
                      children: [
                        searchPageController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF500450)),
                              )
                            : searchPageController.errorMessage.isNotEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error,
                                            size: 80, color: Colors.redAccent),
                                        const SizedBox(height: 20),
                                        Text(
                                          searchPageController.errorMessage,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 18, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () => searchPageController
                                              .fetchLocations(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF500450),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Retry',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : searchPageController
                                        .filteredLocationsList.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.people,
                                                size: 100, color: Colors.grey),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'No locations found.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  searchPageController
                                                      .fetchLocations(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF500450),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Retry',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh:
                                            searchPageController.fetchLocations,
                                        child: ListView.builder(
                                          itemCount: searchPageController
                                              .filteredLocationsList.length,
                                          itemBuilder: (context, index) {
                                            final locationData =
                                                searchPageController
                                                        .filteredLocationsList[
                                                    index];
                                            return LocationWidget(
                                              // img: locationData[
                                              //             'profilepictureurl'] !=
                                              //         null
                                              //     ? locationData[
                                              //             'profilepictureurl'] +
                                              //         '/download?project=66e4476900275deffed4'
                                              //     : '',
                                              name: locationData['name'],
                                              isFollowing: false,
                                              locationId: locationData['id'],
                                              senderId:
                                                  searchPageController.userId!,
                                              isFollowingMap:
                                                  searchPageController
                                                      .isFollowingMap,
                                              storage:
                                                  searchPageController.storage,
                                              setIsFollowingMap:
                                                  searchPageController
                                                      .setIsFollowingMap,
                                            );
                                          },
                                        ),
                                      ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.article_outlined,
                                size: 100, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'No contents.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            // const SizedBox(height: 20),
                            // ElevatedButton(
                            //   onPressed: () => _fetchComments(),
                            //   // Retry fetching comments
                            //   child: const Text('Retry'),
                            // ),
                          ],
                        ),
                        searchPageController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF500450)),
                              )
                            : searchPageController.errorMessage.isNotEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error,
                                            size: 80, color: Colors.redAccent),
                                        const SizedBox(height: 20),
                                        Text(
                                          searchPageController.errorMessage,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 18, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () =>
                                              searchPageController.fetchPages(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF500450),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Retry',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : searchPageController.pages.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.article_outlined,
                                                size: 100, color: Colors.grey),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'No authors available at the moment.',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () => searchPageController
                                                  .fetchPages(), // Retry button
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF500450),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Retry',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh:
                                            searchPageController.fetchPages,
                                        child: ListView.builder(
                                          itemCount:
                                              searchPageController.pages.length,
                                          itemBuilder: (context, index) {
                                            final page = searchPageController
                                                .pages[index];
                                            return PageWidget(
                                              img: page['pageProfilePictureUrl'] !=
                                                      null
                                                  ? "${page['pageProfilePictureUrl']}/download?project=66e4476900275deffed4"
                                                  : '',
                                              name: page['name'],
                                              description: page['description'],
                                              followers:
                                                  '${page['followers'].length} followers',
                                              isFollowing: false,
                                              pageId: page['pageId'],
                                              userId:
                                                  searchPageController.userId,
                                              isFollowingMap:
                                                  searchPageController
                                                      .isFollowingMap,
                                              storage:
                                                  searchPageController.storage,
                                              setIsFollowingMap:
                                                  searchPageController
                                                      .setIsFollowingMap,
                                            );
                                          },
                                        ),
                                      ),
                      ],
                    ),
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
