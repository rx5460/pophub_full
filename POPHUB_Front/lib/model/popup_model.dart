import 'package:pophub/model/schedule_model.dart';

class PopupModel {
  final bool? bookmark;
  final String? username,
      name,
      location,
      contact,
      description,
      status,
      start,
      end,
      id,
      wait,
      x,
      y;
  final int? category, mark, view;
  final List? image;
  final List<Schedule>? schedule; // 새로운 스케줄 리스트 필드

  PopupModel.fromJson(Map<String, dynamic> json)
      : bookmark = json['is_bookmarked'],
        username = json['user_name'],
        name = json['store_name'],
        location = json['store_location'],
        contact = json['store_contact_info'],
        description = json['store_description'],
        status = json['store_status'],
        start = json['store_start_date'],
        end = json['store_end_date'],
        wait = json['store_wait_status'],
        id = json['store_id'],
        category = json['category_id'],
        mark = json['store_mark_number'],
        view = json['store_view_count'],
        image = json.containsKey('imageUrls')
            ? json['imageUrls']
            : json.containsKey('image_urls')
                ? json['image_urls']
                : json['images'],
        schedule = (json['store_schedules'] as List<dynamic>?)
            ?.map((item) => Schedule.fromJson(item as Map<String, dynamic>))
            .toList(),
        x = json['x'],
        y = json['y'];

  Map<String, dynamic> toJson() {
    return {
      'user_name': username,
      'store_name': name,
      'store_location': location,
      'store_contact_info': contact,
      'store_description': description,
      'store_status': status,
      'store_start_date': start,
      'store_end_date': end,
      'store_wait_status': wait,
      'store_id': id,
      'category_id': category,
      'store_mark_number': mark,
      'store_view_count': view,
      'imageUrls': image,
      'store_schedules': schedule?.map((e) => e.toJson()).toList(),
      'x': x,
      'y': y
    };
  }
}
