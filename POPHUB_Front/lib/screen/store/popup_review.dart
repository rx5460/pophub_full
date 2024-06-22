import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/review_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';

class PopupReview extends StatefulWidget {
  final VoidCallback popupDetailRefresh;
  final String storeId, storeName;
  const PopupReview(
      {super.key,
      required this.storeId,
      required this.storeName,
      required this.popupDetailRefresh});

  @override
  State<PopupReview> createState() => _PopupReviewState();
}

class _PopupReviewState extends State<PopupReview> {
  late final TextEditingController contentController = TextEditingController();
  List<ReviewModel>? reviewList;

  bool isLoading = true;
  double rating = 0;
  double _selectedRating = 0; // 선택된 평점

  Future<void> fetchReviewData() async {
    try {
      List<ReviewModel>? dataList = await Api.getReviewList(widget.storeId);

      if (dataList.isNotEmpty) {
        setState(() {
          reviewList = dataList;
          for (int i = 0; i < dataList.length; i++) {
            rating += dataList[i].rating!;
          }
          rating = rating / dataList.length;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching review data: $error');
    }
  }

  Future<void> writeReview() async {
    Map<String, dynamic> data = await Api.writeReview(
        widget.storeId, _selectedRating, contentController.text, User().userId);

    if (!data.toString().contains("fail")) {
      widget.popupDetailRefresh(); // 수정된 부분
      setState(() {
        isLoading = true;
      });

      fetchReviewData();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    fetchReviewData();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: CustomTitleBar(titleName: widget.storeName),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              SizedBox(
                width: screenWidth * 0.9,
                height: screenWidth * 0.3,
                child: TextField(
                  controller: contentController,
                  keyboardType: TextInputType.multiline,
                  minLines: 14,
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFFAdd8E6),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < _selectedRating
                              ? Icons.star
                              : Icons.star_border_outlined,
                          color: index < _selectedRating
                              ? Constants.REVIEW_STAR_CLOLR
                              : Colors.black,
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: writeReview,
                    child: Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.1,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Constants.DEFAULT_COLOR,
                      ),
                      child: const Center(
                        child: Text(
                          '작성',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              for (int index = 0; index < (reviewList?.length ?? 0); index++)
                if (reviewList != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    reviewList![index].user ?? '',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (starIndex) => Icon(
                                  starIndex < (reviewList![index].rating ?? 0)
                                      ? Icons.star
                                      : Icons.star_border_outlined,
                                  size: 20,
                                  color: Constants.REVIEW_STAR_CLOLR,
                                ),
                              ),
                            ),
                            Text(reviewList![index].content ?? ''),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
