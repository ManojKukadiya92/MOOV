import 'package:MOOV/utils/themes_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class DealDetail extends StatelessWidget {
  final String title, pic, description, day;
  const DealDetail(this.title, this.pic, this.description, this.day);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
        backgroundColor: TextThemes.ndBlue,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.all(15),
          title: Text("DEAL", style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Column(
        children: [
          ClipRRect(
            child: Container(
              margin: const EdgeInsets.only(
                  bottom: 6.0), //Same as `blurRadius` i guess
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: OptimizedCacheImage(
                imageUrl: pic,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: TextThemes.headline1),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20),
            child: Row(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("the deets  ",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20))),
                Expanded(
                    child: Divider(
                  thickness: 1,
                  height: 1,
                  color: Colors.black,
                ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              description,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }
}
