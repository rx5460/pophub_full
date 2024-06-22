import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pophub/model/goods_model.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/GoodsNotifier.dart';
import 'package:pophub/screen/goods/goods_add_page.dart';
import 'package:pophub/screen/goods/goods_list.dart';
import 'package:pophub/screen/goods/goods_order.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';
import 'package:provider/provider.dart';

class GoodsDetail extends StatefulWidget {
  final String goodsId;
  final String popupName;
  final String popupId;
  const GoodsDetail(
      {Key? key,
      required this.goodsId,
      required this.popupName,
      required this.popupId})
      : super(key: key);

  @override
  State<GoodsDetail> createState() => _GoodsDetailState();
}

class _GoodsDetailState extends State<GoodsDetail> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  bool isLoading = false;
  bool isBuying = false;
  GoodsModel? goods;
  int count = 1;
  bool addGoodsVisible = false;
  List<GoodsModel> goodsList = [];

  late PopupModel popup;

  @override
  void initState() {
    super.initState();
    fetchGoodsData();
    getGoodsData();
  }

  Future<void> fetchGoodsData() async {
    try {
      List<GoodsModel>? dataList = await Api.getPopupGoodsList(widget.popupId);

      if (dataList.isNotEmpty) {
        setState(() {
          goodsList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching goods data: $error');
    }
  }

  Future<void> getGoodsData() async {
    try {
      GoodsModel? data = await Api.getPopupGoodsDetail(widget.goodsId);

      if (User().userName != "") {
        List<dynamic> popupData = await Api.getMyPopup(User().userName);

        if (!popupData.toString().contains("없습니다")) {
          setState(() {
            goods = data;
            isLoading = true;
            popup = PopupModel.fromJson(popupData[0]);
          });
          if (goods != null) {
            if (popup.id == goods!.store) {
              setState(() {
                addGoodsVisible = true;
              });
            }
          }
        } else {
          setState(() {
            goods = data;
            isLoading = true;
            addGoodsVisible = false;
          });
        }
      } else {
        setState(() {
          goods = data;
          isLoading = true;
          addGoodsVisible = false;
        });
      }
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching goods data: $error');
    }
  }

  Future<void> goodsDelete(String productId) async {
    final data = await Api.goodsDelete(productId);

    if (!data.toString().contains("fail") && mounted) {
      showAlert(context, "성공", "굿즈가 삭제되었습니다.", () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoodsList(
              popup: popup,
            ),
          ),
        ).then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      });
    } else {
      if (mounted) {
        showAlert(context, "실패", "굿즈 삭제 실패했습니다.", () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      body: !isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height:
                          isBuying ? screenHeight * 0.8 : screenHeight * 0.9,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth,
                              height: AppBar().preferredSize.height,
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                            ),
                            Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    sliderWidget(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Transform.translate(
                                          offset: Offset(0, -screenWidth * 0.1),
                                          child: Container(
                                            width: screenWidth * 0.17,
                                            height: screenWidth * 0.06,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${(_current + 1).toString()}/${goods?.image?.length ?? 0}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.05,
                                          right: screenWidth * 0.05),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Text(
                                              goods?.productName ?? '',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${formatNumber(goods!.price)}원',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                size: 20,
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                '1인당 ${goods?.quantity}개까지 구매 가능합니다.',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                top: 12, bottom: 12),
                                            width: screenWidth * 0.9,
                                            child: Text(
                                              goods!.description,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20, bottom: 10),
                                                child: SizedBox(
                                                  width: screenWidth * 0.9,
                                                  child: const Text(
                                                    '이 스토어의 다른 제품들',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: screenWidth,
                                            height: screenWidth * 0.8,
                                            // ListView
                                            child: ListView.builder(
                                                itemCount: goodsList.length,

                                                // physics: const NeverScrollableScrollPhysics(),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  final goods =
                                                      goodsList[index];

                                                  return widget.goodsId !=
                                                          goods.product
                                                      ? Padding(
                                                          padding: EdgeInsets.only(
                                                              left:
                                                                  screenWidth *
                                                                      0.05,
                                                              right: goodsList
                                                                          .length ==
                                                                      index + 1
                                                                  ? screenWidth *
                                                                      0.05
                                                                  : 0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          GoodsDetail(
                                                                    popupName:
                                                                        popup
                                                                            .name!,
                                                                    popupId:
                                                                        popup
                                                                            .id!,
                                                                    goodsId: goods
                                                                        .product,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.5,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child: Image
                                                                        .network(
                                                                      '${goods.image![0]}',
                                                                      // width: screenHeight * 0.07 - 5,
                                                                      width:
                                                                          screenWidth *
                                                                              0.5,
                                                                      height:
                                                                          screenWidth *
                                                                              0.5,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    //     Image.asset(
                                                                    //   'assets/images/Untitled.png',
                                                                    //   width:
                                                                    //       screenWidth *
                                                                    //           0.5,
                                                                    // ),
                                                                    //   fit: BoxFit.cover,)
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                    child: Text(
                                                                      goods
                                                                          .productName,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${goods.quantity.toString()}개',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox();
                                                })),
                                      ],
                                    ),
                                  ],
                                ),
                                goods != null
                                    ? Positioned(
                                        top:
                                            -AppBar().preferredSize.height + 20,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          color: Colors.transparent,
                                          child: AppBar(
                                            systemOverlayStyle:
                                                SystemUiOverlayStyle.dark,
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            leading: IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(
                                                Icons.arrow_back_ios,
                                                color: Colors.white,
                                              ),
                                            ),
                                            actions: [
                                              Visibility(
                                                visible: addGoodsVisible,
                                                child: PopupMenuButton(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Colors.white,
                                                  ),
                                                  onSelected: (value) {
                                                    if (value == 'edit') {
                                                      if (mounted) {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    MultiProvider(
                                                                        providers: [
                                                                          ChangeNotifierProvider(
                                                                              create: (_) => GoodsNotifier())
                                                                        ],
                                                                        child:
                                                                            GoodsCreatePage(
                                                                          mode:
                                                                              "modify",
                                                                          goods:
                                                                              goods,
                                                                          popup:
                                                                              popup,
                                                                          productId:
                                                                              goods!.product,
                                                                        ))));
                                                      }
                                                    } else if (value ==
                                                        'delete') {
                                                      goodsDelete(
                                                          goods!.product);
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (BuildContext context) =>
                                                          [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Text('굿즈 수정'),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Text('굿즈 삭제'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      // duration: const Duration(milliseconds: 300),
                      width: screenWidth,
                      height:
                          isBuying ? screenHeight * 0.2 : screenHeight * 0.1,
                      decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 2,
                              color: Color(0xFFADD8E6),
                            ),
                          ),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05,
                            bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            isBuying
                                ? const SizedBox()
                                : Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.favorite_border,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Text(
                                        '26',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                isBuying
                                    ? SizedBox(
                                        width: screenWidth * 0.8,
                                        height: screenHeight * 0.1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    goods!.productName,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                  Text(
                                                    '${formatNumber(goods!.price)}원',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ]),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (count != 0) {
                                                        count -= 1;
                                                      }
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 20,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Text(
                                                    count.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      count += 1;
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                                Container(
                                  // duration: const Duration(milliseconds: 300),
                                  width: isBuying
                                      ? screenWidth * 0.9
                                      : screenWidth * 0.3,
                                  height: isBuying
                                      ? screenHeight * 0.06
                                      : screenHeight * 0.05,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      border: Border.all(
                                        width: 2,
                                        color: const Color(0xFFADD8E6),
                                      ),
                                      color: const Color(0xFFADD8E6)),
                                  child: InkWell(
                                    onTap: () {
                                      if (User().userName != "") {
                                        setState(() {
                                          if (!isBuying) {
                                            isBuying = !isBuying;
                                          } else {
                                            // 결제페이지
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      GoodsOrder(
                                                        popupName:
                                                            widget.popupName,
                                                        goods: goods!,
                                                        count: count,
                                                      )),
                                            );
                                          }
                                        });
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Login()),
                                        );
                                      }
                                    },
                                    child: const Center(
                                      child: Text(
                                        '구매하기',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isBuying)
                  Positioned(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isBuying = false;
                            });
                          },
                          child: Container(
                            // duration: const Duration(milliseconds: 400),
                            height: screenHeight * 0.8,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: goods!.image!.map(
        (img) {
          return Builder(
            builder: (context) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Image.network(
                        img,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: 0, // 그림자의 위치 조정
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30, // 그림자의 높이 조정
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 50,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ));
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }
}
