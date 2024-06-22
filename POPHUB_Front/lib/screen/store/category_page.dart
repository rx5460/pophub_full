import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/category_model.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/store/store_list_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  List<CategoryModel> category = [];

  @override
  void initState() {
    super.initState();
    getCategory();
    _loadRecentSearches();
  }

  Future<void> getCategory() async {
    final data = await Api.getCategory();
    if (mounted) {
      setState(() {
        category = data.where((item) => item.categoryId >= 10).toList();
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _addRecentSearch(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_recentSearches.contains(search)) {
      _recentSearches.add(search);
      await prefs.setStringList('recentSearches', _recentSearches);
      _loadRecentSearches();
    }
  }

  Future<void> _removeRecentSearch(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(search);
    await prefs.setStringList('recentSearches', _recentSearches);
    _loadRecentSearches();
  }

  void _search(String query) async {
    getPopupByStoreName(query);
    await _addRecentSearch(query);
  }

  Future<void> getPopupByStoreName(String storeName) async {
    final data = await Api.getPopupByName(storeName);
    if (!data.toString().contains("fail") && mounted) {
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => StoreModel())
                        ],
                        child: StoreListPage(
                          popups: data,
                          titleName: "검색 결과",
                        ))));
      }
    } else {}
    setState(() {});
  }

  void _searchByCategory(int category) async {
    final data = await Api.getPopupByCategory(category);
    if (!data.toString().contains("fail") && mounted) {
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => StoreModel())
                        ],
                        child:
                            StoreListPage(popups: data, titleName: "검색 결과"))));
      }
    } else {}
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(
        titleName: "검색",
        useBack: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '어떤 정보를 찾아볼까요?',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _search(_searchController.text);
                    },
                  ),
                ),
              ),
              if (_recentSearches.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('최근 검색어',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _recentSearches
                      .map(
                        (search) => Chip(
                          label: Text(search),
                          onDeleted: () async {
                            await _removeRecentSearch(search);
                          },
                          deleteIcon: const Icon(Icons.clear, size: 20),
                          deleteIconColor: Colors.black,
                          labelStyle: const TextStyle(color: Colors.black),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Constants.DEFAULT_COLOR),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                      .toList(),
                )
              ],
              const SizedBox(height: 16),
              const Text('카테고리',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                ),
                itemCount: category.length,
                itemBuilder: (context, index) {
                  var item = category[index];
                  return GestureDetector(
                    onTap: () => _searchByCategory(item.categoryId),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Constants.DEFAULT_COLOR, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          item.categoryName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
