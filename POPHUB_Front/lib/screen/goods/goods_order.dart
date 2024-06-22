import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/model/goods_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/user/purchase_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';

class GoodsOrder extends StatefulWidget {
  final int count;
  final GoodsModel goods;
  final String popupName;
  const GoodsOrder(
      {super.key,
      required this.count,
      required this.goods,
      required this.popupName});

  @override
  State<GoodsOrder> createState() => _GoodsOrderState();
}

class _GoodsOrderState extends State<GoodsOrder> {
  String kakopayLink = "";
  Map<String, dynamic>? profile;
  int usePoint = 0;

  Future<void> testApi() async {
    final data = await Api.pay(User().userId, widget.goods.productName,
        widget.count, widget.goods.price, widget.goods.price ~/ 10, 0);

    setState(() {
      kakopayLink = data['data'];
    });
  }

  Future<void> profileApi() async {
    try {
      Map<String, dynamic> data = await Api.getProfile(User().userId);

      if (!data.toString().contains("fail")) {
        setState(() {
          profile = data;
          print(profile);
        });

        User().userName = data['userName'];
        User().phoneNumber = data['phoneNumber'];
        User().age = data['age'];
        User().gender = data['gender'];
        User().file = data['userImage'] ?? '';
        User().role = data['userRole'] ?? '';
      }
    } catch (e) {
      Logger.debug('$e');
    }
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await profileApi();
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          '주문/결제',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  top: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('상품 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.popupName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // const Text(
                          //   '위치 확인하기',
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/goods.png',
                          width: screenWidth * 0.2,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.goods.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${formatCurrency(widget.goods.price)}원 x ${widget.count}개 = ${formatCurrency(widget.goods.price * widget.count)}원',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                  width: screenWidth,
                  height: 1,
                  color: const Color(0xFFAdd8E6),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('포인트',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '포인트',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${formatCurrency(usePoint)}p',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  usePoint = profile?['pointScore'];
                                });
                              },
                              child: Container(
                                width: screenWidth * 0.2,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: const Color(0xFFADD8E6),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    color: const Color(0xFFADD8E6)),
                                child: const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Text(
                                    '모두사용',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                )),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Text(
                      '잔여 포인트 : ${formatCurrency(profile?['pointScore'] ?? 0)}p',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                  width: screenWidth,
                  height: 1,
                  color: const Color(0xFFAdd8E6),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('총 결제 금액',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        )),
                    Text(
                      '${formatCurrency(widget.goods.price * widget.count - usePoint)}원',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFADD8E6),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                  width: screenWidth,
                  height: 1,
                  color: const Color(0xFFAdd8E6),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '상품 금액',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${formatCurrency(widget.goods.price * widget.count)}원',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '포인트 할인',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '-${formatCurrency(usePoint)}p',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                  width: screenWidth,
                  height: 1,
                  color: const Color(0xFFAdd8E6),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('결제 방법',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.08,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color(
                            0xFFADD8E6,
                          ),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/kakaopay.png',
                        width: screenWidth * 0.1,
                        // height: 24,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.07,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    width: 2,
                    color: const Color(0xFFADD8E6),
                  ),
                  color: const Color(0xFFADD8E6)),
              child: InkWell(
                onTap: () async {
                  await testApi();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchasePage(
                          api: kakopayLink,
                        ),
                      ),
                    );
                  }
                  Logger.debug("kakopayLink $kakopayLink");
                },
                child: const Center(
                  child: Text(
                    '결제하기',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
