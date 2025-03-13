class Member {
  final int id;
  final String username;
  final String profilePictureUrl; // This can be nullable
  final String description;
  final int viewerUserId; // Add senderId field

  Member({
    required this.id,
    required this.username,
    String? profilePictureUrl, // Make this nullable
    required this.description,
    required this.viewerUserId, // Add senderId as a required parameter
  }) : this.profilePictureUrl =
            profilePictureUrl ?? ''; // Default to empty string if null
}
