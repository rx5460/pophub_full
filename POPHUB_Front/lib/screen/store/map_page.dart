import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/store/popup_detail.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late KakaoMapController mapController;
  List<Map<String, String>> locationList = [];
  Map<String, Set<Marker>> markersMap = {};
  Set<Marker> markers = {};

  bool draggable = true;
  bool zoomable = true;

  Clusterer? clusterer;
  List<PopupModel>? popupList;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        getAllPopupList();
      },
    );
  }

  Future<void> getAllPopupList() async {
    try {
      final markerMap = await Api.getAllPopupList();

      if (markerMap.isNotEmpty) {
        setState(() {
          markersMap = markerMap;
          markers = markerMap.values.expand((set) => set).toSet();
          isLoading = false;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching popup data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(
        titleName: "전체 팝업스토어",
        useBack: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : KakaoMap(
              center: LatLng(37.27943075229118, 127.01763998406159),
              onMapCreated: (controller) {
                mapController = controller;

                clusterer = Clusterer(
                  markers: markers.toList(),
                  minLevel: 10,
                  averageCenter: true,
                );

                setState(() {});
              },
              currentLevel: 14,
              clusterer: clusterer,
              onMarkerClustererTap: (latLng, zoomLevel) async {
                int level = await mapController.getLevel() - 1;

                await mapController.setLevel(
                  level,
                  options: LevelOptions(
                    animate: Animate(duration: 500),
                    anchor: latLng,
                  ),
                );
              },
              onMarkerTap: ((markerId, latLng, zoomLevel) {
                // Find the popup name corresponding to the markerId
                String storeId = markersMap.keys.firstWhere(
                  (name) => markersMap[name]!
                      .any((marker) => marker.markerId == markerId),
                  orElse: () => 'Unknown',
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PopupDetail(
                      storeId: storeId,
                    ),
                  ),
                );
                // ScaffoldMessenger.of(context)
                //     .showSnackBar(SnackBar(content: Text('팝업스토어 이름 $storeId')));
              }),
            ),
    );
  }
}
