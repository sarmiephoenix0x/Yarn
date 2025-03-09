import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/create_community_controller.dart';

class CreateCommunity extends StatefulWidget {
  const CreateCommunity({super.key});

  @override
  CreateCommunityState createState() => CreateCommunityState();
}

class CreateCommunityState extends State<CreateCommunity> {
  @override
  Widget build(BuildContext context) {
    final createCommunityController =
        Provider.of<CreateCommunityController>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Community')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: createCommunityController.nameController,
              decoration: const InputDecoration(hintText: 'Community Name'),
            ),
            TextField(
              controller: createCommunityController.descriptionController,
              decoration:
                  const InputDecoration(hintText: 'Community Description'),
            ),
            // Profile Picture Section
            GestureDetector(
              onTap: createCommunityController.pickProfilePicture,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: createCommunityController.communityProfilePicture != null
                    ? Image.file(
                        File(createCommunityController
                            .communityProfilePicture!.path),
                        fit: BoxFit.cover)
                    : const Center(
                        child: Text('Tap to select profile picture')),
              ),
            ),
            SizedBox(
                height: (20.0 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height),
            Container(
              width: double.infinity,
              height: (60 / MediaQuery.of(context).size.height) *
                  MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  if (createCommunityController.isLoading) {
                    null;
                  } else {
                    createCommunityController.createCommunity(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white;
                      }
                      return const Color(0xFF500450);
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color(0xFF500450);
                      }
                      return Colors.white;
                    },
                  ),
                  elevation: WidgetStateProperty.all<double>(4.0),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(35)),
                    ),
                  ),
                ),
                child: createCommunityController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Community',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
