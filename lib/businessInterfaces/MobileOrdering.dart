import 'dart:io';
import 'package:MOOV/main.dart';
import 'package:MOOV/moovMoney/moovMoneyAdd.dart';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worm_indicator/indicator.dart';
import 'package:worm_indicator/shape.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MobileOrdering extends StatelessWidget {
  final String userId, postId;
  MobileOrdering({this.userId, this.postId});

  final PageController controller =
      PageController(initialPage: 0, viewportFraction: .8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        backgroundColor: TextThemes.ndBlue,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.all(5),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Image.asset(
                  'lib/assets/moovblue.png',
                  fit: BoxFit.cover,
                  height: 50.0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder(
          stream: usersRef.doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return linearProgress();
            }
            Map mobileOrderMenu = snapshot.data['mobileOrderMenu'];
            Map item1 = mobileOrderMenu['item1'];
            Map item2 = mobileOrderMenu['item2'];
            Map item3 = mobileOrderMenu['item3'];

            return (postId != null)
                ?

                ///this menu is being viewed from a specific post
                StreamBuilder(
                    stream: postsRef.doc(postId).snapshots(),
                    builder: (context, snapshotPost) {
                      if (!snapshotPost.hasData) {
                        return Container();
                      }

                      int itemsOffered = 0;
                      bool offeringItem1 =
                          snapshotPost.data['mobileOrderMenu']['item1'];
                      bool offeringItem2 =
                          snapshotPost.data['mobileOrderMenu']['item2'];
                      bool offeringItem3 =
                          snapshotPost.data['mobileOrderMenu']['item3'];

                      if (offeringItem1) {
                        itemsOffered++;
                      }
                      if (offeringItem2) {
                        itemsOffered++;
                      }
                      if (offeringItem3) {
                        itemsOffered++;
                      }

                      return Column(
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              offeringItem1
                                  ? GestureDetector(
                                      onTap: () => controller.animateToPage(0,
                                          duration: Duration(seconds: 1),
                                          curve: Curves.fastOutSlowIn),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                (1 / itemsOffered),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10),
                                            item1.isNotEmpty
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            item1['photo']))
                                                : Icon(
                                                    Icons.brunch_dining,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                            SizedBox(height: 5),
                                            item1.isNotEmpty
                                                ? SizedBox(
                                                    height: 35,
                                                    child: Text(
                                                      item1['name'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  )
                                                : Text("Item\nOne",
                                                    textAlign:
                                                        TextAlign.center),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              offeringItem2
                                  ? GestureDetector(
                                      onTap: () => controller.animateToPage(1,
                                          duration: Duration(seconds: 1),
                                          curve: Curves.fastOutSlowIn),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                (1 / itemsOffered),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10),
                                            item2.isNotEmpty
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            item2['photo']))
                                                : Image.asset(
                                                    'lib/assets/marg.png',
                                                    height: 40),
                                            SizedBox(height: 5),
                                            item2.isNotEmpty
                                                ? SizedBox(
                                                    height: 35,
                                                    child: Text(
                                                      item2['name'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  )
                                                : Text("Item\nTwo",
                                                    textAlign:
                                                        TextAlign.center),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              offeringItem3
                                  ? GestureDetector(
                                      onTap: () => controller.animateToPage(2,
                                          duration: Duration(seconds: 1),
                                          curve: Curves.fastOutSlowIn),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                (1 / itemsOffered),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10),
                                            item3.isNotEmpty
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            item3['photo']))
                                                : Icon(
                                                    Icons.local_pizza,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                            SizedBox(height: 5),
                                            item3.isNotEmpty
                                                ? SizedBox(
                                                    height: 35,
                                                    child: Text(
                                                      item3['name'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  )
                                                : Text("Item\nThree",
                                                    textAlign:
                                                        TextAlign.center),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          Expanded(
                            child: MobileOrderPageView(
                              controller: controller,
                              mobileOrderMenu: mobileOrderMenu,
                              userId: userId,
                              postId: postId,
                              offeringItem1: offeringItem1,
                              offeringItem2: offeringItem2,
                              offeringItem3: offeringItem3,
                              itemsOffered: itemsOffered,
                            ),
                          )
                        ],
                      );
                    })
                :

                ///business is viewing the menu, this is not associated with a post
                Column(
                    children: [
                      SizedBox(height: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => controller.animateToPage(0,
                                duration: Duration(seconds: 1),
                                curve: Curves.fastOutSlowIn),
                            child: Container(
                              width: MediaQuery.of(context).size.width * .333,
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  item1.isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(item1['photo']))
                                      : Icon(
                                          Icons.brunch_dining,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                  SizedBox(height: 5),
                                  item1.isNotEmpty
                                      ? SizedBox(
                                          height: 35,
                                          child: Text(
                                            item1['name'],
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        )
                                      : Text("Item\nOne",
                                          textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.animateToPage(1,
                                duration: Duration(seconds: 1),
                                curve: Curves.fastOutSlowIn),
                            child: Container(
                              width: MediaQuery.of(context).size.width * .333,
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  item2.isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(item2['photo']))
                                      : Image.asset('lib/assets/marg.png',
                                          height: 40),
                                  SizedBox(height: 5),
                                  item2.isNotEmpty
                                      ? SizedBox(
                                          height: 35,
                                          child: Text(
                                            item2['name'],
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        )
                                      : Text("Item\nTwo",
                                          textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.animateToPage(2,
                                duration: Duration(seconds: 1),
                                curve: Curves.fastOutSlowIn),
                            child: Container(
                              width: MediaQuery.of(context).size.width * .333,
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  item3.isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(item3['photo']))
                                      : Icon(
                                          Icons.local_pizza,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                  SizedBox(height: 5),
                                  item3.isNotEmpty
                                      ? SizedBox(
                                          height: 35,
                                          child: Text(
                                            item3['name'],
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        )
                                      : Text("Item\nThree",
                                          textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: MobileOrderPageView(
                            controller: controller,
                            mobileOrderMenu: mobileOrderMenu,
                            userId: userId,
                            postId: postId),
                      )
                    ],
                  );
          }),
    );
  }
}

class MobileOrderPageView extends StatefulWidget {
  final Map mobileOrderMenu;
  final PageController controller;
  final String userId, postId;
  final bool offeringItem1, offeringItem2, offeringItem3;
  final int itemsOffered;

  MobileOrderPageView(
      {this.controller,
      this.mobileOrderMenu,
      this.userId,
      this.postId,
      this.offeringItem1,
      this.offeringItem2,
      this.offeringItem3,
      this.itemsOffered});

  @override
  _MobileOrderPageViewState createState() => _MobileOrderPageViewState();
}

class _MobileOrderPageViewState extends State<MobileOrderPageView> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Column(
      children: [
        SizedBox(height: 15),
        WormIndicator(
          length: widget.itemsOffered != null ? widget.itemsOffered : 3,
          controller: widget.controller,
          shape: Shape(
              width: isLargePhone ? 135 : 100,
              height: 18,
              spacing: 0,
              shape: DotShape.Rectangle),
        ),
        Expanded(
            child: 
            PageView(
          controller: widget.controller,
          children: [
            widget.offeringItem1 == false
                ? Container()
                : MobileItemOne(widget.mobileOrderMenu['item1'], widget.userId,
                    widget.postId),
            widget.offeringItem2 == false
                ? Container()
                : MobileItemTwo(widget.mobileOrderMenu['item2'], widget.userId,
                    widget.postId),
            widget.offeringItem3 == false
                ? Container()
                : MobileItemThree(widget.mobileOrderMenu['item3'],
                    widget.userId, widget.postId),
          ],
        )),
      ],
    );
  }
}

class MobileItemOne extends StatelessWidget {
  final Map item1;
  final String userId, postId;
  MobileItemOne(this.item1, this.userId, this.postId);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 50),
              Card(
                  elevation: 20,
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        item1.isNotEmpty
                            ? SizedBox(
                                width: 300,
                                child: Text(
                                  item1['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue[900]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Text('Add an item',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color: TextThemes.ndBlue)),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: item1.isNotEmpty
                              ? SizedBox(
                                  width: 300,
                                  child: Text(item1['description'],
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.blue[900])),
                                )
                              : Text(
                                  'Describe your item. Customers can then pay for it in advance.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: TextThemes.ndBlue)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: TextThemes.ndBlue,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: item1.isNotEmpty
                                  ? Text(
                                      "\$" +
                                          item1['price'].toString() +
                                          " " +
                                          item1['itemType'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.blue[900]))
                                  : Text(
                                      'Set your price, and any customizations.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: TextThemes.ndBlue)),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              elevation: 5.0,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              showBottomSheet(
                                  backgroundColor: Colors.grey[100],
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  builder: (context) => currentUser.id == userId
                                      ? BottomSheetWidget(1)
                                      : BottomSheetBuy(
                                          1,
                                          item1['price'],
                                          item1['name'],
                                          item1['photo'],
                                          userId,
                                          postId));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: currentUser.id == userId
                                  ? Text('Set it',
                                      style: TextStyle(color: Colors.white))
                                  : Text('Buy',
                                      style: TextStyle(color: Colors.white)),
                            ))
                      ],
                    ),
                  )),
            ],
          ),
          Positioned(
              top: 20,
              child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue[50],
                  child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 41,
                      backgroundImage: item1.isNotEmpty
                          ? NetworkImage(item1['photo'])
                          : null,
                      child: item1.isNotEmpty
                          ? null
                          : Icon(Icons.brunch_dining,
                              size: 50, color: Colors.grey))))
        ],
      ),
    );
  }
}

class MobileItemTwo extends StatelessWidget {
  final Map item2;
  final String userId, postId;
  MobileItemTwo(this.item2, this.userId, this.postId);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 50),
              Card(
                  elevation: 20,
                  color: Colors.pink[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        item2.isNotEmpty
                            ? SizedBox(
                                width: 300,
                                child: Text(
                                  item2['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.pink[900]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Text('Margarita',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.pink[900])),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: item2.isNotEmpty
                              ? SizedBox(
                                  width: 300,
                                  child: Text(item2['description'],
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.pink[900])),
                                )
                              : Text(
                                  'Our famous margs come frozen or regular. 21+ only.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.pink[900])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.pink[900],
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: item2.isNotEmpty
                                  ? Text(
                                      "\$" +
                                          item2['price'].toString() +
                                          " " +
                                          item2['itemType'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.pink[900]))
                                  : Text("\$7 regular\n\$10 frozen",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.pink[900])),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.pink,
                              elevation: 5.0,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              showBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  builder: (context) => currentUser.id == userId
                                      ? BottomSheetWidget(2)
                                      : BottomSheetBuy(
                                          2,
                                          item2['price'],
                                          item2['name'],
                                          item2['photo'],
                                          userId,
                                          postId));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: currentUser.id == userId
                                  ? Text('Set it',
                                      style: TextStyle(color: Colors.white))
                                  : Text('Buy',
                                      style: TextStyle(color: Colors.white)),
                            ))
                      ],
                    ),
                  )),
            ],
          ),
          Positioned(
              top: 20,
              child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.red[50],
                  child: CircleAvatar(
                      backgroundImage: item2.isNotEmpty
                          ? NetworkImage(item2['photo'])
                          : null,
                      child: item2.isNotEmpty
                          ? null
                          : Image.asset('lib/assets/marg.png', height: 70),
                      radius: 41,
                      backgroundColor: Colors.white)))
        ],
      ),
    );
  }
}

class MobileItemThree extends StatelessWidget {
  final Map item3;
  final String userId, postId;
  MobileItemThree(this.item3, this.userId, this.postId);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 50),
              Card(
                  elevation: 20,
                  color: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        item3.isNotEmpty
                            ? SizedBox(
                                width: 300,
                                child: Text(
                                  item3['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange[900]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Text('Item three',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange[900])),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: item3.isNotEmpty
                              ? SizedBox(
                                  width: 300,
                                  child: Text(item3['description'],
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.yellow[900])),
                                )
                              : Text('Another description.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.yellow[900])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.yellow[900],
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: item3.isNotEmpty
                                  ? Text(
                                      "\$" +
                                          item3['price'].toString() +
                                          " " +
                                          item3['itemType'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.yellow[900]))
                                  : Text(
                                      "Hint: Easy-to-make items are best, customers can then easily show their receipt and grab it!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.yellow[900])),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                              elevation: 5.0,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              showBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  builder: (context) => currentUser.id == userId
                                      ? BottomSheetWidget(3)
                                      : BottomSheetBuy(
                                          3,
                                          item3['price'],
                                          item3['name'],
                                          item3['photo'],
                                          userId,
                                          postId));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: currentUser.id == userId
                                  ? Text('Set it',
                                      style: TextStyle(color: Colors.white))
                                  : Text('Buy',
                                      style: TextStyle(color: Colors.white)),
                            ))
                      ],
                    ),
                  )),
            ],
          ),
          Positioned(
              top: 20,
              child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.orange[50],
                  child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 41,
                      backgroundImage: item3.isNotEmpty
                          ? NetworkImage(item3['photo'])
                          : null,
                      child: item3.isNotEmpty
                          ? null
                          : Icon(Icons.local_pizza,
                              size: 50, color: Colors.grey))))
        ],
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  final int itemNumber;
  BottomSheetWidget(this.itemNumber);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      height: 375,
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedTextField(widget.itemNumber),
          ]),
    );
  }
}

class DecoratedTextField extends StatefulWidget {
  final int itemNumber;
  DecoratedTextField(this.itemNumber);

  _DecoratedTextFieldState createState() => _DecoratedTextFieldState();
}

class _DecoratedTextFieldState extends State<DecoratedTextField> {
  File _image;
  bool isUploading = false;
  bool success = false;

  var placeholderImage;
  final picker = ImagePicker();

  void openCamera(context) async {
    final image = await CustomCamera.openCamera();
    setState(() {
      _image = image;
      //  fileName = p.basename(_image.path);
    });
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        cropStyle: CropStyle.circle,
        maxHeight: 100,
        sourcePath: _image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Croperooni',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Croperooni',
        ));
    if (croppedFile != null) {
      setState(() {
        _image = croppedFile;
      });
    }
  }

  void openGallery(context) async {
    final image = await CustomCamera.openGallery();
    setState(() {
      _image = image;
    });
    _cropImage();
  }

  Future handleTakePhoto() async {
    Navigator.pop(context);
    final file = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file.path);
      }
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final file = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file.path);
      }
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Whaddaya got? 😋",
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Photo with Camera",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openCamera(context);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              //    child: Text("Image from Gallery", style: TextStyle(color: Colors.white),), onPressed: handleChooseFromGallery),
              //    child: Text("Image from Gallery", style: TextStyle(color: Colors.white),), onPressed: () => openGallery(context)),
              child: Text(
                "Image from Gallery",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openGallery(context);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, true),
            )
          ],
        );
      },
    );
  }

  String priceString, nameString, descriptionString, typeString;
  int priceInt;
  bool emptyFields = false, noImage = false;
  final priceController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return (success)
        ? Center(
            child: Icon(
              Icons.check,
              size: 100,
              color: Colors.green,
            ),
          )
        : Column(
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: 43,
                      backgroundColor: Colors.orange[50],
                      child: CircleAvatar(
                        backgroundImage: FileImage(_image),
                        radius: 41,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => selectImage(context),
                      child: CircleAvatar(
                          radius: noImage ? 46 : 43,
                          backgroundColor: noImage
                              ? Colors.red
                              : widget.itemNumber == 1
                                  ? Colors.blue[50]
                                  : widget.itemNumber == 2
                                      ? Colors.pink[50]
                                      : Colors.orange[50],
                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 41,
                              child: Icon(Icons.local_pizza,
                                  size: 50, color: Colors.grey))),
                    ),
              Container(
                  height: 50,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration.collapsed(
                        hintText: 'Enter your item name',
                        hintStyle:
                            emptyFields ? TextStyle(color: Colors.red) : null),
                  )),
              Container(
                  height: 50,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration.collapsed(
                        hintText: 'Describe it',
                        hintStyle:
                            emptyFields ? TextStyle(color: Colors.red) : null),
                  )),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: "Price",
                              hintStyle: emptyFields
                                  ? TextStyle(color: Colors.red)
                                  : null),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            CurrencyTextInputFormatter(
                              decimalDigits: 0,
                              symbol: '\$',
                            )
                          ],
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() => priceString = value);
                            if (value != "0") {
                              String x = priceController.text
                                  .substring(1)
                                  .replaceAll(",", "");
                              priceInt = int.parse(x);
                            }
                          },
                        )),
                  ),
                  Flexible(
                    flex: 5,
                    child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: typeController,
                          decoration: InputDecoration.collapsed(
                              hintText: 'Item type (ex: Frozen)',
                              hintStyle: emptyFields
                                  ? TextStyle(color: Colors.red)
                                  : null),
                        )),
                  ),
                ],
              ),
              !isUploading
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: widget.itemNumber == 1
                            ? Colors.blue
                            : widget.itemNumber == 2
                                ? Colors.pink
                                : Colors.orange,
                        elevation: 5.0,
                      ),
                      onPressed: () async {
                        if (_image == null) {
                          setState(() {
                            noImage = true;
                          });
                        }
                        if (nameController.text.isEmpty ||
                            descriptionController.text.isEmpty ||
                            priceInt == null ||
                            typeController.text.isEmpty) {
                          setState(() {
                            emptyFields = true;
                          });
                        } else if (nameController.text.isNotEmpty &&
                            descriptionController.text.isNotEmpty &&
                            priceInt != null &&
                            typeController.text.isNotEmpty &&
                            _image != null) {
                          setState(() {
                            isUploading = true;
                          });
                          firebase_storage.Reference ref;
                          firebase_storage.UploadTask uploadTask;
                          firebase_storage.TaskSnapshot taskSnapshot;
                          String downloadUrl = "";
                          ref = firebase_storage.FirebaseStorage.instance
                              .ref()
                              .child("images/" +
                                  currentUser.id +
                                  "mobileOrderMenu/${widget.itemNumber}");
                          uploadTask = ref.putFile(_image);
                          taskSnapshot = await uploadTask;
                          if (uploadTask.snapshot.state ==
                              firebase_storage.TaskState.success) {
                            print("added to Firebase Storage");
                            downloadUrl =
                                await taskSnapshot.ref.getDownloadURL();
                            usersRef.doc(currentUser.id).set({
                              "mobileOrderMenu": {
                                "item${widget.itemNumber}": {
                                  "name": nameController.text,
                                  "description": descriptionController.text,
                                  "price": priceInt,
                                  "itemType": typeController.text,
                                  "photo": downloadUrl
                                }
                              },
                            }, SetOptions(merge: true));
                          }

                          setState(() {
                            isUploading = false;
                            success = true;
                          });
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : isUploading
                      ? linearProgress()
                      : Container()
            ],
          );
  }
}

class BottomSheetBuy extends StatefulWidget {
  final int itemNumber, price;
  final String name, photo, businessUserId, postId;
  BottomSheetBuy(this.itemNumber, this.price, this.name, this.photo,
      this.businessUserId, this.postId);

  @override
  _BottomSheetBuyState createState() => _BottomSheetBuyState();
}

class _BottomSheetBuyState extends State<BottomSheetBuy> {
  bool isLoading = false;
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? linearProgress()
        : (success)
            ? Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Done!",
                          style: TextStyle(color: Colors.green, fontSize: 35)),
                      SizedBox(height: 40),
                      Icon(
                        Icons.check,
                        size: 100,
                        color: Colors.green,
                      )
                    ]),
              )
            : Container(
                margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                height: 300,
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: widget.itemNumber == 1
                              ? Colors.blue[50]
                              : widget.itemNumber == 2
                                  ? Colors.pink[50]
                                  : Colors.orange[50],
                          child: CircleAvatar(
                            radius: 41,
                            backgroundImage: NetworkImage(widget.photo),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: widget.itemNumber == 1
                                ? Colors.blue[900]
                                : widget.itemNumber == 2
                                    ? Colors.pink[900]
                                    : Colors.orange[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 20),
                        child: Text("\$" + widget.price.toString(),
                            style: TextStyle(fontSize: 20)),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: widget.itemNumber == 1
                                ? Colors.blue
                                : widget.itemNumber == 2
                                    ? Colors.pink
                                    : Colors.orange,
                            elevation: 5.0,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              isLoading = true;
                            });
                            if (currentUser.moovMoney < widget.price) {
                              showBottomSheet(
                                  backgroundColor: Colors.white,
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  builder: (context) => BottomSheetDeposit());
                            } else {
                              String passId = generateRandomString(20);

                              usersRef.doc(currentUser.id).set({
                                "moovMoney":
                                    FieldValue.increment(widget.price * -1)
                              }, SetOptions(merge: true));
                              usersRef.doc(widget.businessUserId).set({
                                "moovMoney": FieldValue.increment(widget.price)
                              }, SetOptions(merge: true));

                              usersRef
                                  .doc(currentUser.id)
                                  .collection("livePasses")
                                  .doc(passId)
                                  .set({
                                "name": widget.name,
                                "type": "item",
                                "price": widget.price,
                                "photo": widget.photo,
                                "time": Timestamp.now(),
                                "businessId": widget.businessUserId,
                                "postId": widget.postId,
                                "passId": passId,
                                "tip": 0
                              }, SetOptions(merge: true)).then(
                                      (value) => setState(() {
                                            isLoading = false;
                                            success = true;
                                          }));
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pop(context);
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Confirm',
                                style: TextStyle(color: Colors.white)),
                          ))
                    ]),
              );
  }
}

class BottomSheetDeposit extends StatelessWidget {
  const BottomSheetDeposit({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        height: 200,
        width: MediaQuery.of(context).size.width * .95,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 41,
                backgroundImage: AssetImage('lib/assets/mm.png')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("You don't have enough MOOV Money!"),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: TextThemes.ndGold,
                elevation: 5.0,
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MoovMoneyAdd(0, currentUser.moovMoney))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Deposit', style: TextStyle(color: Colors.white)),
              ))
        ]));
  }
}
