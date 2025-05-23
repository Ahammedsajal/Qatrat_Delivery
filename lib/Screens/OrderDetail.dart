import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Helper/AppBtn.dart';

import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Order_Model.dart';

class OrderDetail extends StatefulWidget {
  final Order_Model? model;
  final Function? updateHome;
  const OrderDetail({
    super.key,
    this.model,
    this.updateHome,
  });
  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  List<String> statusList = [
    PLACED,
    PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
    RETURNED,
    WAITING,
  ];
  bool? _isCancleable;
  bool? _isReturnable;
  final bool _isLoading = true;
  bool _isProgress = false;
  String? curStatus;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? otpC;
  @override
  void initState() {
    super.initState();
    curStatus = widget.model!.activeStatus;
    for (int i = 0; i < widget.model!.itemList!.length; i++) {
      widget.model!.itemList![i].curSelected =
          widget.model!.itemList![i].status;
    }
    if (widget.model!.payMethod == "Bank Transfer") {
      statusList.removeWhere((final element) => element == PLACED);
    }
    buttonController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
      vsync: this,
    );
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled catch (_) {}
  }

  Widget noInternet(final BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, TRY_AGAIN_INT_LBL),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();
                Future.delayed(const Duration(seconds: 2)).then(
                  (final _) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (final BuildContext context) => super.widget,
                        ),
                      );
                    } else {
                      await buttonController!.reverse();
                      setState(
                        () {},
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    final Order_Model model = widget.model!;
    String? pDate;
    String? prDate;
    String? sDate;
    String? dDate;
    String? cDate;
    String? rDate;
    if (model.listStatus!.contains(PLACED)) {
      pDate = model.listDate![model.listStatus!.indexOf(
        PLACED,
      )];
      if (pDate != "") {
        final List d = pDate!.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(PROCESSED)) {
      prDate = model.listDate![model.listStatus!.indexOf(PROCESSED)];
      if (prDate != "") {
        final List d = prDate!.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(SHIPED)) {
      sDate = model.listDate![model.listStatus!.indexOf(SHIPED)];
      if (sDate != "") {
        final List d = sDate!.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(DELIVERD)) {
      dDate = model.listDate![model.listStatus!.indexOf(DELIVERD)];
      if (dDate != "") {
        final List d = dDate!.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(CANCLED)) {
      cDate = model.listDate![model.listStatus!.indexOf(CANCLED)];
      if (cDate != "") {
        final List d = cDate!.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(RETURNED)) {
      rDate = model.listDate![model.listStatus!.indexOf(RETURNED)];
      if (rDate != "") {
        final List d = rDate!.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }
    _isCancleable = model.isCancleable == "1" ? true : false;
    _isReturnable = model.isReturnable == "1" ? true : false;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      appBar: getAppBar(
        getTranslated(context, ORDER_DETAIL)!,
        context,
      ),
      body: _isNetworkAvail
          ? Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                elevation: 0,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${getTranslated(context, ORDER_ID_LBL)!} - ${model.id!}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightfontColor2,
                                            ),
                                      ),
                                      Text(
                                        "${getTranslated(context, ORDER_DATE)!} - ${model.orderDate!}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightfontColor2,
                                            ),
                                      ),
                                      Text(
                                        "${getTranslated(context, PAYMENT_MTHD)!} - ${model.payMethod!}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightfontColor2,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (model.delDate != "" &&
                                  model.delDate!.isNotEmpty)
                                Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "${getTranslated(context, PREFER_DATE_TIME)!}: ${model.delDate!} - ${model.delTime!}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightfontColor2,
                                          ),
                                    ),
                                  ),
                                )
                              else
                                Container(),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: model.itemList!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (final context, final i) {
                                  final OrderItem orderItem =
                                      model.itemList![i];
                                  return productItem(orderItem, model, i);
                                },
                              ),
                              shippingDetails(),
                              priceDetails(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: DropdownButtonFormField(
                                dropdownColor:
                                    Theme.of(context).colorScheme.lightWhite,
                                iconEnabledColor:
                                    Theme.of(context).colorScheme.fontColor,
                                hint: Text(
                                  getTranslated(context, UpdateStatus)!,
                                  style: Theme.of(this.context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  fillColor:
                                      Theme.of(context).colorScheme.lightWhite,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                    ),
                                  ),
                                ),
                                value: statusList
                                        .contains(widget.model!.activeStatus)
                                    ? widget.model!.activeStatus
                                    : RETURNED,
                                onChanged: (final dynamic newValue) {
                                  setState(
                                    () {
                                      curStatus = newValue;
                                    },
                                  );
                                },
                                items: statusList.map(
                                  (final String st) {
                                    return DropdownMenuItem<String>(
                                      value: st,
                                      child: Text(
                                        capitalize(st),
                                        style: Theme.of(this.context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            constraints: const BoxConstraints.expand(
                              width: 42,
                              height: 42,
                            ),
                            onPressed: () {
                              if (model.otp != "" &&
                                  model.otp!.isNotEmpty &&
                                  model.otp != "0" &&
                                  curStatus == DELIVERD) {
                                otpDialog(
                                  curStatus,
                                  model.otp,
                                  model.id,
                                  false,
                                  0,
                                );
                              } else {
                                updateOrder(
                                  curStatus,
                                  updateOrderApi,
                                  model.id,
                                  false,
                                  0,
                                );
                              }
                            },
                            fillColor: Theme.of(context).colorScheme.fontColor,
                            padding: const EdgeInsets.only(left: 5),
                            shape: const CircleBorder(),
                            child: Align(
                              child: Icon(
                                Icons.send,
                                size: 20,
                                color: Theme.of(context).colorScheme.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                showCircularProgress(
                  _isProgress,
                  Theme.of(context).colorScheme.primarytheme,
                ),
              ],
            )
          : noInternet(context),
    );
  }

  otpDialog(
    final String? curSelected,
    final String? otp,
    final String? id,
    final bool item,
    final int index,
  ) async {
    await showDialog(
      context: context,
      builder: (final BuildContext context) {
        return StatefulBuilder(
          builder: (final BuildContext context, final StateSetter setStater) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    5.0,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        20.0,
                        0,
                        2.0,
                      ),
                      child: Text(
                        OTP_LBL,
                        style: Theme.of(this.context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                            ),
                      ),
                    ),
                    const Divider(),
                    Form(
                      key: _formkey,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              20.0,
                              0,
                              20.0,
                              0,
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (final String? value) {
                                if (value!.isEmpty) {
                                  return getTranslated(context, FIELD_REQUIRED);
                                } else if (value.trim() != otp) {
                                  return getTranslated(context, OTPERROR);
                                } else {
                                  return null;
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, OTP_ENTER),
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightfontColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              controller: otpC,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, CANCEL)!,
                    style: Theme.of(this.context)
                        .textTheme
                        .titleSmall!
                        .copyWith(
                          color: Theme.of(context).colorScheme.lightfontColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, SEND_LBL)!,
                    style:
                        Theme.of(this.context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  onPressed: () {
                    final form = _formkey.currentState!;
                    if (form.validate()) {
                      form.save();
                      setState(
                        () {
                          Navigator.pop(context);
                        },
                      );
                      updateOrder(
                        curSelected,
                        updateOrderApi,
                        id,
                        item,
                        index,
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  _launchMap(final lat, final lng) async {
    var url = '';
    if (Platform.isAndroid) {
      url =
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url =
          "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }
    await launchUrl(Uri.parse(url));
  }

  priceDetails() {
  return Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Text(
              getTranslated(context, PRICE_DETAIL)!,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: _priceRow(
              getTranslated(context, PRICE_LBL)!,
              double.tryParse(widget.model!.subTotal ?? '0') ?? 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: _priceRow(
              getTranslated(context, DELIVERY_CHARGE_LBL)!,
              double.tryParse(widget.model!.delCharge ?? '0') ?? 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: _priceRow(
              "${getTranslated(context, TAXPER)!} (${widget.model!.taxPer ?? '0'})",
              double.tryParse(widget.model!.taxAmt ?? '0') ?? 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: _priceRow(
              getTranslated(context, PROMO_CODE_DIS_LBL)!,
              -(double.tryParse(widget.model!.promoDis ?? '0') ?? 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: _priceRow(
              getTranslated(context, WALLET_BAL)!,
              -(double.tryParse(widget.model!.walBal ?? '0') ?? 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: _priceRow(
              getTranslated(context, TOTAL_PRICE)!,
              double.tryParse(widget.model!.total ?? '0') ?? 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: _priceRow(
              getTranslated(context, TOTAL_AMOUNT)!,
              double.tryParse(widget.model!.payable ?? '0') ?? 0,
              isBold: true,
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper function for rendering price rows
Widget _priceRow(String label, double amount, {bool isBold = false}) {
  final style = Theme.of(context).textTheme.labelLarge!.copyWith(
        color: isBold
            ? Theme.of(context).colorScheme.lightfontColor
            : Theme.of(context).colorScheme.lightfontColor2,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      );
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("$label :", style: style),
      Text(getPriceFormat(context, amount)!, style: style),
    ],
  );
}

  shippingDetails() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          15.0,
          0,
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                children: [
                  Text(
                    getTranslated(context, SHIPPING_DETAIL)!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 30,
                    child: IconButton(
                      icon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      onPressed: () {
                        _launchMap(
                          widget.model!.latitude,
                          widget.model!.longitude,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Text(
                widget.model!.name != "" && widget.model!.name!.isNotEmpty
                    ? " ${capitalize(widget.model!.name!)}"
                    : " ",
              ),
            ),
            if (widget.model!.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 3,
                ),
                child: Text(
                  widget.model!.address!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.lightfontColor2,
                  ),
                ),
              )
            else
              Container(),
            if (widget.model!.mobile!.isNotEmpty)
              InkWell(
                onTap: _launchCaller,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.call,
                        size: 15,
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      Text(
                        " ${widget.model!.mobile!}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(),
          ],
        ),
      ),
    );
  }

  productItem(
    final OrderItem orderItem,
    final Order_Model model,
    final int i,
  ) {
    List? att;
    List? val;
    if (orderItem.attr_name!.isNotEmpty) {
      att = orderItem.attr_name!.split(',');
      val = orderItem.varient_values!.split(',');
    }
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 150),
                    image: NetworkImage(orderItem.image!),
                    height: 90.0,
                    width: 90.0,
                    placeholder: placeHolder(90),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderItem.name ?? '',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightfontColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (orderItem.attr_name!.isNotEmpty)
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: att!.length,
                            itemBuilder: (final context, final index) {
                              return Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      att![index].trim() + ":",
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightfontColor2,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      val![index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightfontColor,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        else
                          Container(),
                        Row(
                          children: [
                            Text(
                              "${getTranslated(context, QUANTITY_LBL)!}:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightfontColor2,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                orderItem.qty!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightfontColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (orderItem.status == 'return_request_approved' ||
                            orderItem.status == 'return_request_pending' ||
                            orderItem.status == 'return_request_decline')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${getTranslated(context, 'ACTIVE_STATUS_LBL')!}:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightfontColor,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      () {
                                        if (capitalize(orderItem.status!) ==
                                            "Received") {
                                          return getTranslated(
                                            context,
                                            "received",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Processed") {
                                          return getTranslated(
                                            context,
                                            "processed",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Shipped") {
                                          return getTranslated(
                                            context,
                                            "shipped",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Delivered") {
                                          return getTranslated(
                                            context,
                                            "delivered",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Returned") {
                                          return getTranslated(
                                            context,
                                            "returned",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Cancelled") {
                                          return getTranslated(
                                            context,
                                            "cancelled",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Return_request_pending") {
                                          return getTranslated(
                                            context,
                                            "RETURN_REQUEST_PENDING_LBL",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Return_request_approved") {
                                          return getTranslated(
                                            context,
                                            "RETURN_REQUEST_APPROVE_LBL",
                                          )!;
                                        } else if (capitalize(
                                              orderItem.status!,
                                            ) ==
                                            "Return_request_decline") {
                                          return getTranslated(
                                            context,
                                            "RETURN_REQUEST_DECLINE_LBL",
                                          )!;
                                        }
                                        return capitalize(orderItem.status!);
                                      }(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          getPriceFormat(
                            context,
                            double.parse(orderItem.price!),
                          )!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                              ),
                        ),
                        if (widget.model!.itemList!.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: DropdownButtonFormField(
                                      dropdownColor: Theme.of(context)
                                          .colorScheme
                                          .lightWhite,
                                      iconEnabledColor: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      hint: Text(
                                        getTranslated(
                                          context,
                                          UpdateStatus,
                                        )!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        isDense: true,
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .lightWhite,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                          ),
                                        ),
                                      ),
                                      value: (orderItem.status ==
                                                  'return_request_approved' ||
                                              orderItem.status ==
                                                  'return_request_pending' ||
                                              orderItem.status ==
                                                  'return_request_decline')
                                          ? null
                                          : orderItem.status,
                                      onChanged: (final dynamic newValue) {
                                        setState(
                                          () {
                                            orderItem.curSelected = newValue;
                                          },
                                        );
                                      },
                                      items: statusList.map(
                                        (final String st) {
                                          return DropdownMenuItem<String>(
                                            value: st,
                                            child: Text(
                                              capitalize(st),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .fontColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                                RawMaterialButton(
                                  constraints: const BoxConstraints.expand(
                                    width: 42,
                                    height: 42,
                                  ),
                                  onPressed: () {
                                    if (model.otp != "" &&
                                        model.otp!.isNotEmpty &&
                                        model.otp != "0" &&
                                        orderItem.curSelected == DELIVERD) {
                                      otpDialog(
                                        orderItem.curSelected,
                                        model.otp,
                                        model.id,
                                        true,
                                        i,
                                      );
                                    } else {
                                      updateOrder(
                                        orderItem.curSelected,
                                        updateOrderApi,
                                        model.id,
                                        true,
                                        i,
                                      );
                                    }
                                  },
                                  fillColor:
                                      Theme.of(context).colorScheme.fontColor,
                                  padding: const EdgeInsets.only(left: 5),
                                  shape: const CircleBorder(),
                                  child: Align(
                                    child: Icon(
                                      Icons.send,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


Future<void> updateOrder(
  final String? status,
  final Uri api,
  final String? id,
  final bool item,
  final int index, {
  List<String>? imagePaths, // Optional parameter for image file paths
}) async {
  _isNetworkAvail = await isNetworkAvailable();
  if (_isNetworkAvail) {
    try {
      setState(() {
        _isProgress = true;
      });
      final parameter = {
        ORDERID: id,
        STATUS: status,
        DEL_BOY_ID: CUR_USERID,
      };
      if (item) parameter[ORDERITEMID] = widget.model!.itemList![index].id;

      // If imagePaths are provided, send a multipart request
      if (imagePaths != null && imagePaths.isNotEmpty) {
        var request = MultipartRequest("POST", api);
request.fields.addAll(
  parameter.map((key, value) => MapEntry(key, value ?? ''))
);
        // Attach each image file to the request
        for (var path in imagePaths) {
          if (path != null) {
            File file = File(path);
            var stream = MultipartFile.fromBytes(
              'images[]', // field name for images (adjust as needed by your backend)
              await file.readAsBytes(),
filename: file.path.split('/').last,
            );
            request.files.add(stream);
          }
        }
        var streamedResponse = await request.send();
        var response = await Response.fromStream(streamedResponse);
        final getdata = json.decode(response.body);
        final bool error = getdata["error"];
        final String msg = getdata["message"];
        setSnackbar(msg);
        if (!error) {
          if (item) {
            widget.model!.itemList![index].status = status;
          } else {
            widget.model!.activeStatus = status;
          }
        }
      } else {
        // Fallback to the basic POST if no images are provided
        final Response response = await post(
          item ? updateOrderItemApi : updateOrderApi,
          body: parameter,
          headers: headers,
        ).timeout(
          const Duration(seconds: timeOut),
        );
        final getdata = json.decode(response.body);
        final bool error = getdata["error"];
        final String msg = getdata["message"];
        setSnackbar(msg);
        if (!error) {
          if (item) {
            widget.model!.itemList![index].status = status;
          } else {
            widget.model!.activeStatus = status;
          }
        }
      }
      setState(() {
        _isProgress = false;
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, somethingMSg)!);
    }
  } else {
    setState(() {
      _isNetworkAvail = false;
    });
  }
}


  _launchCaller() async {
    final url = "tel:${widget.model!.mobile}";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  setSnackbar(final String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
        ),
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 1.0,
      ),
    );
  }
}
