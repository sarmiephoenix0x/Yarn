import 'package:flutter/material.dart';

class AuthorDetails extends StatelessWidget {
  final String authorName;
  final bool verified;
  final bool anonymous;

  const AuthorDetails({
    super.key,
    required this.authorName,
    required this.verified,
    required this.anonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!anonymous) ...[
          Row(
            children: [
              Text(
                authorName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              //if (verified) Image.asset('images/verified.png', height: 20),
            ],
          ),
          Text(
            '@$authorName',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
            ),
          ),
        ] else
          const Text(
            'Anonymous',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
