import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/category_model.dart';
import 'package:pophub/model/kopo_model.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/schedule_model.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/nav/bottom_navigation_page.dart';
import 'package:pophub/screen/store/store_operate_hour_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/remedi_kopo.dart';
import 'package:pophub/utils/utils.dart';
import 'package:provider/provider.dart';

class StoreCreatePage extends StatefulWidget {
  final String mode;
  final PopupModel? popup;

  const StoreCreatePage({super.key, this.mode = "add", this.popup});

  @override
  _StoreCreatePageState createState() => _StoreCreatePageState();
}

class _StoreCreatePageState extends State<StoreCreatePage> {
  List<CategoryModel> category = [];
  @override
  void initState() {
    super.initState();
    _initializeFields();
    getCategory();
  }

  void _initializeFields() {
    if (widget.popup != null) {
      _nameController.text = widget.popup?.name ?? '';
      _descriptionController.text = widget.popup?.description ?? '';

      String locationPart = "";
      if (widget.popup?.location != null &&
          widget.popup!.location!.isNotEmpty) {
        List<String> parts = widget.popup!.location!.split("/");
        if (parts.length > 1) {
          locationPart = parts[1];
        }
      }

      _locationController.text = locationPart;
      _contactController.text = widget.popup?.contact ?? '';
      _maxCapacityController.text = widget.popup?.view?.toString() ?? '';

      Provider.of<StoreModel>(context, listen: false).name =
          widget.popup?.name ?? '';
      Provider.of<StoreModel>(context, listen: false).description =
          widget.popup?.description ?? '';
      Provider.of<StoreModel>(context, listen: false).location =
          widget.popup?.location ?? '';
      Provider.of<StoreModel>(context, listen: false).contact =
          widget.popup?.contact ?? '';
      Provider.of<StoreModel>(context, listen: false).maxCapacity =
          widget.popup?.view ?? 0;

      Provider.of<StoreModel>(context, listen: false).startDate =
          DateTime.parse(widget.popup?.start ?? DateTime.now().toString());
      Provider.of<StoreModel>(context, listen: false).endDate =
          DateTime.parse(widget.popup?.end ?? DateTime.now().toString());

      Provider.of<StoreModel>(context, listen: false).schedule =
          widget.popup!.schedule;

      Provider.of<StoreModel>(context, listen: false).id = widget.popup!.id!;

      Provider.of<StoreModel>(context, listen: false).category =
          widget.popup?.category?.toString() ?? '';
      Provider.of<StoreModel>(context, listen: false).images = widget
              .popup?.image
              ?.map((imageUrl) => {'type': 'url', 'data': imageUrl})
              .toList() ??
          [];
    }
  }

  Future<void> getCategory() async {
    final data = await Api.getCategory();
    setState(() {
      category = data.where((item) => item.categoryId >= 10).toList();
      if (widget.popup != null) {
        selectedCategory = category.firstWhere(
          (item) =>
              item.categoryId.toString() == widget.popup?.category.toString(),
        );
      }
    });
    print("Data $data");
  }

  final ImagePicker _picker = ImagePicker();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  CategoryModel? selectedCategory;

  Future<void> _pickImage() async {
    try {
      if (Provider.of<StoreModel>(context, listen: false).images.length < 5) {
        final XFile? pickedImage =
            await _picker.pickImage(source: ImageSource.gallery);

        if (pickedImage != null && mounted) {
          Provider.of<StoreModel>(context, listen: false)
              .addImage({'type': 'file', 'data': File(pickedImage.path)});
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('경고'),
                content: const Text('사진은 최대 5개까지 등록할 수 있습니다.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? Provider.of<StoreModel>(context, listen: false).startDate
          : Provider.of<StoreModel>(context, listen: false).endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      if (isStartDate) {
        Provider.of<StoreModel>(context, listen: false).updateStartDate(picked);
      } else {
        DateTime startDate =
            Provider.of<StoreModel>(context, listen: false).startDate;
        if (picked.isBefore(startDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('운영 종료일은 운영 시작일 이전으로 설정할 수 없습니다.'),
            ),
          );
        } else {
          Provider.of<StoreModel>(context, listen: false).updateEndDate(picked);
        }
      }
    }
  }

  bool _validateInputs(StoreModel store) {
    if (_nameController.text.isEmpty) {
      _showValidationDialog("스토어 이름을 입력해주세요.");
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      _showValidationDialog("스토어 설명을 입력해주세요.");
      return false;
    }
    if (store.location.isEmpty) {
      _showValidationDialog("스토어 위치를 선택해주세요.");
      return false;
    }
    if (_contactController.text.isEmpty) {
      _showValidationDialog("연락처를 입력해주세요.");
      return false;
    }
    if (widget.mode == "add" && _maxCapacityController.text.isEmpty) {
      _showValidationDialog("시간별 최대 인원을 입력해주세요.");
      return false;
    }
    if (store.schedule!.isEmpty) {
      _showValidationDialog("운영 시간을 설정해주세요.");
      return false;
    }
    if (selectedCategory == null) {
      _showValidationDialog("카테고리를 선택해주세요.");
      return false;
    }
    return true;
  }

  void _showValidationDialog(String message) {
    showAlert(context, "실패", message, () {
      Navigator.of(context).pop();
    });
  }

  Future<void> _pickLocation() async {
    if (!mounted) return;

    KopoModel? model = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RemediKopo(),
      ),
    );

    if (model != null && model.address != null) {
      if (mounted) {
        Provider.of<StoreModel>(context, listen: false)
            .updateLocation(model.address!);
      }
    }
  }

  Future<void> storeAdd(StoreModel store) async {
    final data = await Api.storeAdd(store);

    if (!data.toString().contains("fail") && mounted) {
      showAlert(context, "성공", "팝업스토어 신청이 완료되었습니다.", () {
        Navigator.of(context).pop();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(providers: [
                      ChangeNotifierProvider(create: (_) => UserNotifier())
                    ], child: const BottomNavigationPage())));
      });
    } else {}
  }

  Future<void> storeModify(StoreModel store) async {
    final data = await Api.storeModify(store);

    if (!data.toString().contains("fail") && mounted) {
      showAlert(context, "성공", "팝업스토어 수정이 완료되었습니다.", () {
        Navigator.of(context).pop();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(providers: [
                      ChangeNotifierProvider(create: (_) => UserNotifier())
                    ], child: const BottomNavigationPage())));
      });
    } else {}
  }

  void _showOperatingHoursModal(BuildContext context, StoreModel storeModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StoreOperatingHoursModal(storeModel: storeModel);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      appBar: CustomTitleBar(
          titleName: widget.mode == "modify" ? "스토어 수정" : "스토어 추가"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<StoreModel>(
          builder: (context, store, child) {
            return ListView(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () => _pickImage(),
                          child: const Icon(Icons.add),
                        ),
                      ),
                      ...store.images
                          .map((image) => Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: image['type'] == 'file'
                                        ? Image.file(
                                            image['data'],
                                            width: 60,
                                            height: 60,
                                          )
                                        : Image.network(
                                            image['data'],
                                            width: 60,
                                            height: 60,
                                          ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => store.removeImage(image),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "스토어 이름",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름을 작성해주세요.'),
                  onChanged: (value) => store.name = value,
                ),
                const SizedBox(height: 20),
                const Text(
                  "스토어 설명",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: '스토어 설명을 작성해주세요.', alignLabelWithHint: true),
                  maxLines: 4,
                  onChanged: (value) => store.description = value,
                ),
                const SizedBox(height: 20),
                const Text(
                  "스토어 위치",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Constants.BUTTON_GREY),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: const Text(
                      '스토어 위치',
                    ),
                    subtitle: store.location.isNotEmpty
                        ? Text(store.location.split("/").first)
                        : null,
                    trailing: const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                    ),
                    onTap: () => _pickLocation(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: '상세 위치를 적어주세요.'),
                  onChanged: (value) => store.locationDetail = value,
                ),
                const SizedBox(height: 20),
                const Text(
                  "운영 시간",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Constants.BUTTON_GREY),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: const Text(
                      '운영 시간 설정하기',
                    ),
                    trailing: const Icon(Icons.access_time,
                        color: Constants.DARK_GREY),
                    onTap: () {
                      _showOperatingHoursModal(context, store);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Visibility(
                  visible: store.schedule!.isNotEmpty,
                  child: SizedBox(
                    width: screenWidth * 0.5,
                    height:
                        screenHeight * (store.schedule!.length * 0.2) * 0.22,
                    child: Consumer<StoreModel>(
                      builder: (context, store, child) {
                        return store.schedule != null
                            ? ListView.builder(
                                itemCount: store.schedule!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  Schedule schedule = store.schedule![index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(getDayOfWeekAbbreviation(
                                                schedule.dayOfWeek, "ko")),
                                            const SizedBox(width: 8),
                                            Text(
                                                '${formatTime(schedule.openTime)} ~ ${formatTime(schedule.closeTime)}'),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            store.removeScheduleAt(index);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(0),
                                            child: Icon(
                                              Icons.close,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Container();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "운영 기간",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Constants.BUTTON_GREY),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: const Text(
                            '운영 시작일',
                          ),
                          subtitle: Text(
                            _dateFormat.format(store.startDate),
                          ),
                          trailing: const Icon(
                            Icons.calendar_today,
                            color: Constants.DARK_GREY,
                          ),
                          onTap: () => _selectDate(true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Constants.BUTTON_GREY),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: const Text(
                            '운영 종료일',
                          ),
                          subtitle: Text(
                            _dateFormat.format(store.endDate),
                          ),
                          trailing: const Icon(
                            Icons.calendar_today,
                            color: Constants.DARK_GREY,
                          ),
                          onTap: () => _selectDate(false),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "연락처",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: '연락처'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: (value) => store.contact = value,
                ),
                const SizedBox(height: 20),
                Visibility(
                    visible: widget.mode == "add",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "시간별 최대 인원",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            controller: _maxCapacityController,
                            decoration:
                                const InputDecoration(labelText: '시간별 최대 인원'),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1000),
                            ],
                            onChanged: (value) => {
                                  if (value != '')
                                    {store.maxCapacity = int.parse(value)},
                                }),
                        const SizedBox(height: 20),
                      ],
                    )),
                const Text(
                  "카테고리",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<CategoryModel>(
                  decoration: const InputDecoration(labelText: '카테고리'),
                  value: selectedCategory,
                  items: category.map((categoryModel) {
                    return DropdownMenuItem<CategoryModel>(
                      value: categoryModel,
                      child: Text(categoryModel.categoryName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                        store.category = value.categoryId.toString();
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: OutlinedButton(
                    onPressed: () {
                      if (_validateInputs(store)) {
                        if (widget.mode == "modify") {
                          storeModify(store);
                        } else if (widget.mode == "add") {
                          storeAdd(store);
                        }
                      }
                    },
                    child: const Text('완료'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
