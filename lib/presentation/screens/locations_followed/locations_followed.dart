import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/location_widget.dart';
import '../../controllers/locations_followed_controller.dart';

class LocationsFollowedPage extends StatefulWidget {
  final int senderId;

  const LocationsFollowedPage({super.key, required this.senderId});

  @override
  _LocationsFollowedPageState createState() => _LocationsFollowedPageState();
}

class _LocationsFollowedPageState extends State<LocationsFollowedPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          LocationsFollowedController(senderId: widget.senderId),
      child: Consumer<LocationsFollowedController>(
        builder: (context, locationsFollowedController, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Locations Followed'),
            ),
            body: locationsFollowedController.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF500450)),
                  )
                : locationsFollowedController.errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error,
                                size: 80, color: Colors.redAccent),
                            const SizedBox(height: 20),
                            Text(
                              locationsFollowedController.errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () =>
                                  locationsFollowedController.fetchFollowed(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF500450),
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
                    : locationsFollowedController.locationsList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people,
                                    size: 100, color: Colors.grey),
                                const SizedBox(height: 20),
                                const Text(
                                  'No locations found.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => locationsFollowedController
                                      .fetchFollowed(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF500450),
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
                            itemCount: locationsFollowedController
                                .locationsList.length,
                            itemBuilder: (context, index) {
                              final locationData = locationsFollowedController
                                  .locationsList[index];
                              return LocationWidget(
                                img: locationData['profilepictureurl'] != null
                                    ? locationData['profilepictureurl'] +
                                        '/download?project=66e4476900275deffed4'
                                    : '',
                                name: locationData['name'],
                                isFollowing: locationData['isFollowing'],
                                locationId: locationData['id'],
                                senderId: widget.senderId,
                                isFollowingMap:
                                    locationsFollowedController.isFollowingMap,
                                storage: locationsFollowedController.storage,
                                setIsFollowingMap: locationsFollowedController
                                    .setIsFollowingMap,
                              );
                            },
                          ),
          );
        },
      ),
    );
  }
}
