import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../../core/widgets/post_widgets/create_options.dart';
import '../../../core/widgets/post_widgets/posts_widget.dart';
import '../../controllers/home_page_controller.dart';
import '../messages_page/messages_page.dart';
import '../notification_page/notification_page.dart';
import 'widgets/icon_button.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final HubConnection? hubConnection;

  const HomePage(
      {super.key,
      required this.selectedIndex,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      this.hubConnection});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      Provider.of<HomePageController>(context).didChangeDependenciesCall();
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homePageController = Provider.of<HomePageController>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () =>
            showCreateOptions(context, homePageController.resetHasFetchedData),
        backgroundColor: const Color(0xFF500450),
        shape: const CircleBorder(),
        child: Image.asset(
          'images/User-talk.png',
          height: 30,
          fit: BoxFit.cover,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xFF500450).withOpacity(0.8),
              elevation: 2,
              titleSpacing: 20,
              toolbarHeight: 70.0,
              title: Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20.0), // Adjust padding here
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/AppLogo.png',
                      height: 55,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    IconButtonWidget(
                        assetPath: 'images/NotificationIcon.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(
                                key: UniqueKey(),
                                selectedIndex: widget.selectedIndex,
                              ),
                            ),
                          );
                        }),
                    IconButtonWidget(
                        assetPath: 'images/ChatImg.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeassagesPage(
                                key: UniqueKey(),
                                senderId: homePageController.userId!,
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: homePageController.fetchPosts,
                child: homePageController.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF500450)),
                      )
                    : homePageController.posts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.article_outlined,
                                    size: 100, color: Colors.grey.shade600),
                                const SizedBox(height: 20),
                                Text(
                                  'No yarns available at the moment.',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () =>
                                      homePageController.fetchPosts(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF500450),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller:
                                homePageController.timelineScrollController,
                            itemCount: homePageController.posts.length + 1,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (index == homePageController.posts.length) {
                                return homePageController.hasMore
                                    ? const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                              color: Color(0xFF500450)),
                                        ),
                                      )
                                    : const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Text('No more yarns'),
                                        ),
                                      );
                              }

                              final post = homePageController.posts[index];
                              return PostsWidget(
                                post: post,
                                isLikedNotifiers:
                                    homePageController.isLikedNotifiers,
                                likesNotifier: homePageController.likesNotifier,
                                commentsMap: homePageController.commentsMap,
                                profileImage: homePageController.profileImage,
                                submitCommentMethod:
                                    homePageController.submitComment,
                                toggleLike: homePageController.toggleLike,
                                userId: homePageController.userId,
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
