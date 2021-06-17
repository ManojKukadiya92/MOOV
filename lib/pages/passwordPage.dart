import 'package:MOOV/pages/create_account.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordPage extends StatefulWidget {
  PasswordPage({Key key}) : super(key: key);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

final titleController = TextEditingController();

class _PasswordPageState extends State<PasswordPage> {
  bool _incorrect = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: TextThemes.ndBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Password",
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20)),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: 15.0, left: 15, right: 15, top: 15),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),

                    controller: titleController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: _incorrect
                            ? Icon(Icons.lock, color: Colors.red)
                            : Icon(Icons.lock_open, color: Colors.white),
                        onPressed: () {
                          _tryUnlock();
                          titleController.clear();
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          borderSide: BorderSide(
                            color: Colors.teal,
                          )),
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      _tryUnlock();
                    },
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Title?';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            )));
  }

  _tryUnlock() {
    if (titleController.text == "Unicorn22") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CreateAccount()),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _incorrect = true;
      });
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   titleController.dispose();
  // }
}
