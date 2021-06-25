import 'package:MOOV/maps/Heatmap.dart';
import 'package:MOOV/pages/friend_finder.dart';
import 'package:MOOV/pages/home.dart';
import 'package:flutter/material.dart';

class SecondCarousel extends StatelessWidget {
  final ValueNotifier<double> notifier;

  const SecondCarousel({Key key, this.notifier}) : super(key: key);

  Color _colorTween(Color begin, Color end) {
    return ColorTween(begin: begin, end: end).transform(notifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      width: MediaQuery.of(context).size.width * .89,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: currentUser.isBusiness
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceEvenly,
            children: [
              currentUser.isBusiness
                  ? Container()
                  : GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FriendFinder())),
                      child: Stack(
                        children: [
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 250),
                            opacity: 1 - notifier.value,
                            child: Column(
                              children: [
                                Image.asset('lib/assets/friendsIcon.png',
                                    height: 60),
                                SizedBox(height: 5),
                                Text(
                                  "Find Friends",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 250),
                            opacity: notifier.value,
                            child: Column(
                              children: [
                                Image.asset('lib/assets/friendsIconWhite.png',
                                    height: 60),
                                SizedBox(height: 5),
                                Text(
                                  "Find Friends",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Heatmap())),
                child: Stack(
                  children: [
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 250),
                      opacity: 1 - notifier.value,
                      child: Column(
                        children: [
                          Image.asset('lib/assets/mapIcon.png', height: 60),
                          SizedBox(height: 5),
                          Text(
                            "Find Everyone",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 250),
                      opacity: notifier.value,
                      child: Column(
                        children: [
                          Image.asset('lib/assets/mapIconWhite.png',
                              height: 60),
                          SizedBox(height: 5),
                          Text(
                            "Find Everyone",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
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
  }
}
