import 'package:MOOV/main.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:flutter/material.dart';

class FeatureDealDialog extends StatefulWidget {
  final String title, description, choice1, choice2, image, postTitle;

  const FeatureDealDialog(
      {Key key,
      this.title,
      this.description,
      this.choice1,
      this.choice2,
      this.image,
      this.postTitle});

  @override
  _FeatureDealDialogState createState() => _FeatureDealDialogState();
}

class _FeatureDealDialogState extends State<FeatureDealDialog> {
  bool isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isChecking ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: isLargePhone ? 140 : 110,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.description,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Text(
                "Want to send your MOOV to the top of the list? Text (631) 560-9452 for a quick price estimate.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: TextThemes.ndBlue,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Container(
            child: Stack(alignment: Alignment.center, children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Image.asset(
                  'lib/assets/lead.png',
                  color: TextThemes.ndBlue,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    alignment: Alignment(0.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.black.withAlpha(0),
                            Colors.black,
                            Colors.black12,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Stand Out",
                          style: TextStyle(
                              fontFamily: 'Solway',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
