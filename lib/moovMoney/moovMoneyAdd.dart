import 'dart:async';

import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_braintree/flutter_braintree.dart';

//this pag4 handles deposits and withdraws of MOOV Money
class MoovMoneyAdd extends StatelessWidget {
  final int amount;
  final int currentBalance;
  MoovMoneyAdd(this.amount, this.currentBalance);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

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
        backgroundColor: Colors.white,
        body: ListView(
          physics: ClampingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .15,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  child: ClipRRect(
                    child: Image.asset(
                      'lib/assets/moovmoney.png',
                      color: Colors.black12,
                      colorBlendMode: BlendMode.darken,
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin:
                      EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 7.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 15),
                Text("Current Balance",
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                SizedBox(height: 5),
                Text("\$" + currentBalance.toString(),
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 23)),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                      // height: 80,
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          """Use MOOV Money to buy anything at your MOOVs. """,
                          // """Drinks at the bar, Venmo for house covers, skipping lines, club dues, you name it.""",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: isLargePhone ? 14 : 12),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
                MoneyAmount(amount),

                // ElevatedButton(
                //   onPressed: () async {
                //     var request = BraintreeDropInRequest(
                //       vaultManagerEnabled: true,
                //       applePayRequest: BraintreeApplePayRequest(
                //           amount: 0.01,
                //           displayName: "MOOV MONEY",
                //           countryCode: "US",
                //           currencyCode: "USD",
                //           appleMerchantID: "merchant.com.MOOV.ND"),
                //       venmoEnabled: true,
                //       tokenizationKey: tokenizationKey,
                //       collectDeviceData: true,
                //       googlePaymentRequest: BraintreeGooglePaymentRequest(
                //         totalPrice: '0.01',
                //         currencyCode: 'USD',
                //         billingAddressRequired: false,
                //       ),
                //       paypalRequest: BraintreePayPalRequest(
                //         amount: '0.01',
                //         displayName: 'Example company',
                //       ),
                //       cardEnabled: true,
                //     );
                //     final result = await
                //     BraintreeDropIn.start(request);
                //     if (result != null) {
                //       showNonce(result.paymentMethodNonce, context);
                //     }
                //   },
                //   child: Text('LAUNCH NATIVE DROP-IN'),
                // ),
                // ElevatedButton(
                //   onPressed: () async {
                //     final request = BraintreeCreditCardRequest(
                //       cardNumber: '4111111111111111',
                //       expirationMonth: '12',
                //       expirationYear: '2021',
                //       cvv: '123',
                //     );
                //     final result = await Braintree.tokenizeCreditCard(
                //       tokenizationKey,
                //       request,
                //     );
                //     if (result != null) {
                //       showNonce(result, context);
                //     }
                //   },
                //   child: Text('TOKENIZE CREDIT CARD'),
                // ),
                // ElevatedButton(
                //   onPressed: () async {
                //     final request = BraintreePayPalRequest(
                //       billingAgreementDescription:
                //           'I hereby agree that flutter_braintree is great.',
                //       displayName: 'Your Company',
                //     );
                //     final result = await Braintree.requestPaypalNonce(
                //       tokenizationKey,
                //       request,
                //     );
                //     if (result != null) {
                //       showNonce(result, context);
                //     }
                //   },
                //   child: Text('PAYPAL VAULT FLOW'),
                // ),
                // ElevatedButton(
                //   onPressed: () async {
                //     final request = BraintreePayPalRequest(amount: '13.37');
                //     final result = await Braintree.requestPaypalNonce(
                //       tokenizationKey,
                //       request,
                //     );
                //     if (result != null) {
                //       showNonce(result, context);
                //     }
                //   },
                //   child: Text('PAYPAL CHECKOUT FLOW'),
                // ),
              ],
            ),
          ],
        ));
  }
}

class MoneyAmount extends StatefulWidget {
  final int amountInt;
  MoneyAmount(this.amountInt);

  @override
  _MoneyAmountState createState() => _MoneyAmountState();
}

class _MoneyAmountState extends State<MoneyAmount> {
  static final String tokenizationKey = 'sandbox_x6rsh5jt_63hmws26h3ncb2m4';
  bool successCheck = false;
  bool isUploading = false;

  void showNonce(BraintreePaymentMethodNonce nonce, context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey,
        title: Text('Payment method nonce:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Nonce: ${nonce.nonce}'),
            SizedBox(height: 16),
            Text('Type label: ${nonce.typeLabel}'),
            SizedBox(height: 16),
            Text('Description: ${nonce.description}'),
          ],
        ),
      ),
    );
  }

  String amountString;
  int amountInt;
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return (isUploading)
        ? linearProgress()
        : (successCheck)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sweet!",
                      style: TextThemes.headline1,
                    ),
                    SizedBox(height: 30),
                    Icon(
                      Icons.check,
                      color: Colors.green,
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 50),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 150),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "\$",
                                  hintStyle:
                                      TextStyle(fontWeight: FontWeight.w100)),
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                CurrencyTextInputFormatter(
                                  decimalDigits: 0,
                                  symbol: '\$',
                                )
                              ],
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() => amountString = value);
                                if (value != "0") {
                                  String x = amountController.text
                                      .substring(1)
                                      .replaceAll(",", "");
                                  amountInt = int.parse(x);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();

                      var request = BraintreeDropInRequest(
                        // clientToken: clientToken,
                        vaultManagerEnabled: true,
                        applePayRequest: BraintreeApplePayRequest(
                            amount: amountInt.toDouble(),
                            displayName: "MOOV MONEY",
                            countryCode: "US",
                            currencyCode: "USD",
                            appleMerchantID: "merchant.com.MOOV.ND"),
                        venmoEnabled: true,
                        tokenizationKey: tokenizationKey,
                        collectDeviceData: true,
                        googlePaymentRequest: BraintreeGooglePaymentRequest(
                          totalPrice: amountInt.toString(),
                          currencyCode: 'USD',
                          billingAddressRequired: false,
                        ),
                        paypalRequest: BraintreePayPalRequest(
                          amount: amountInt.toString(),
                          displayName: 'MOOV',
                        ),
                        cardEnabled: true,
                      );
                      final result = await BraintreeDropIn.start(request);
                      if (result != null) {
                        setState(() {
                          isUploading = true;
                        });
                        usersRef
                            .doc(currentUser.id)
                            .collection('payments')
                            .doc()
                            .set({
                          "nonce": result.paymentMethodNonce.nonce,
                          "amount": amountInt,
                          "orderDate": DateTime.now(),
                          // "orderId": orderId,
                          "deviceData": "iPhone",
                        }, SetOptions(merge: true));
                        usersRef
                            .doc(currentUser.id)
                            .set(
                                {"moovMoney": FieldValue.increment(amountInt)}, SetOptions(merge: true))
                            .then((value) => setState(() {
                                  isUploading = false;
                                  successCheck = true;
                                }))
                            .then((value) => Timer(Duration(seconds: 3), () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()),
                                    (Route<dynamic> route) => false,
                                  );
                                }));
                      }
                    },
                    child: Container(
                      height: 50.0,
                      width: 300.0,
                      decoration: BoxDecoration(
                        color: TextThemes.ndGold,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Center(
                        child: Text(
                          "Deposit",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              );
  }
}
