import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomListTileWithLeaguesP extends StatelessWidget {
  final ImageProvider<Object> photo;
  final String title;
  final String subtitle;
  final String additionalText;
  final VoidCallback onPressed;

  const CustomListTileWithLeaguesP({
    required this.photo,
    required this.title,
    required this.subtitle,
    required this.additionalText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: photo,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(subtitle),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(additionalText),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: onPressed,
              ),
            ],
          ),
          onTap: () {
            // Your onTap action
          },
        ),
      ),
    );
  }
}

class CustomListTileWithScoresP extends StatelessWidget {
  final ImageProvider<Object> photo1;
  final String team1;
  final String subtitle1;
  final int score1;
  final int score2;
  final String team2;
  final String subtitle2;
  final ImageProvider<Object> photo2;

  const CustomListTileWithScoresP({
    required this.photo1,
    required this.team1,
    required this.subtitle1,
    required this.score1,
    required this.score2,
    required this.team2,
    required this.subtitle2,
    required this.photo2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: photo1,
          ),
          title: Container(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        team1,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        subtitle1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                FittedBox(
                  child: Text(
                    '$score1 - $score2',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        team2,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        subtitle2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: CircleAvatar(
            radius: 20,
            backgroundImage: photo2,
          ),
        ),
      ),
    );
  }
}

