import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/cinema_models.dart';

Future<List<MovieData>> fetchMovies() async {
  final response = await http.get(Uri.parse('$apiBaseUrl/api/movies'));
  if (response.statusCode != 200) {
    throw Exception('Failed to load movies (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Invalid movie response');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(MovieData.fromJson)
      .toList();
}

Future<List<ScheduleSlot>> fetchSchedulesForMovie(int movieId) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/schedules/movie/$movieId'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to load schedules (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Invalid schedule response');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(ScheduleSlot.fromJson)
      .toList();
}

Future<List<SeatModel>> fetchSeatsForSchedule(int scheduleId) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/seats/schedule/$scheduleId'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to load seats (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Invalid seat response');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(SeatModel.fromJson)
      .toList();
}

Future<Map<String, dynamic>> createBooking({
  required int userId,
  required int scheduleId,
  required List<int> seatIds,
  String walletType = 'Virtual Account',
  String phoneNumber = '080000000000',
  double? walletBalance,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/api/bookings'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'scheduleId': scheduleId,
      'seatIds': seatIds,
      'walletType': walletType,
      'phoneNumber': phoneNumber,
      'walletBalance': walletBalance,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }

  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) return decoded;
  return {};
}

Future<List<BookingHistoryItem>> fetchBookingHistory(int userId) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/bookings/user/$userId'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to load booking history (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Invalid booking history response');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(BookingHistoryItem.fromJson)
      .toList();
}

Future<ProfileSummary> fetchProfileSummary(int userId) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/bookings/user/$userId/profile'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to load profile summary (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic>) {
    throw Exception('Invalid profile summary response');
  }

  return ProfileSummary.fromJson(decoded);
}

Future<String> uploadImageFile(String path) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$apiBaseUrl/api/uploads/image'),
  );
  request.files.add(await http.MultipartFile.fromPath('file', path));
  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  if (response.statusCode != 200) {
    throw Exception(response.body.isNotEmpty ? response.body : 'Upload failed');
  }
  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) {
    final url = decoded['url']?.toString() ?? '';
    if (url.isEmpty) {
      throw Exception('Upload response missing url');
    }
    return url;
  }
  throw Exception('Invalid upload response');
}

Future<String> uploadImageBytes({
  required String filename,
  required Uint8List bytes,
}) async {
  if (bytes.isEmpty) {
    throw Exception('Selected file is empty');
  }

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$apiBaseUrl/api/uploads/image'),
  );
  request.files.add(
    http.MultipartFile.fromBytes('file', bytes, filename: filename),
  );
  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  if (response.statusCode != 200) {
    throw Exception(response.body.isNotEmpty ? response.body : 'Upload failed');
  }
  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) {
    final url = decoded['url']?.toString() ?? '';
    if (url.isEmpty) {
      throw Exception('Upload response missing url');
    }
    return url;
  }
  throw Exception('Invalid upload response');
}

Future<List<PromotionItem>> fetchPromotions() async {
  final response = await http.get(Uri.parse('$apiBaseUrl/api/ads'));
  if (response.statusCode != 200) {
    throw Exception('Failed to load promotions (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Invalid promotion response');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(PromotionItem.fromJson)
      .toList();
}

Future<void> saveAdvertisement({
  int? id,
  required String title,
  required String imageUrl,
  String linkUrl = '',
  bool active = true,
  int sortOrder = 0,
}) async {
  final isUpdate = id != null && id > 0;
  final request = http.Request(
    isUpdate ? 'PUT' : 'POST',
    Uri.parse('$apiBaseUrl/api/ads${isUpdate ? '/$id' : ''}'),
  );
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({
    'title': title,
    'imageUrl': imageUrl,
    'linkUrl': linkUrl,
    'active': active,
    'sortOrder': sortOrder,
  });
  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  if (response.statusCode != 200) {
    throw Exception(
      response.body.isNotEmpty ? response.body : 'Failed to save advertisement',
    );
  }
}

Future<void> deleteAdvertisement(int id) async {
  final response = await http.delete(Uri.parse('$apiBaseUrl/api/ads/$id'));
  if (response.statusCode != 200) {
    throw Exception('Failed to delete advertisement');
  }
}

Future<void> changePassword({
  required String email,
  required String currentPassword,
  required String newPassword,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/api/auth/change-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      response.body.isNotEmpty ? response.body : 'Change password failed',
    );
  }
}

Future<List<MovieData>> fetchAdminMovies() => fetchMovies();

Future<MovieData> saveAdminMovie({
  int? id,
  required String title,
  required String code,
  required String genre,
  required int duration,
  required String synopsis,
  required double price,
  required String imageUrl,
  required String status,
}) async {
  final isUpdate = id != null && id > 0;
  final request = http.Request(
    isUpdate ? 'PUT' : 'POST',
    Uri.parse('$apiBaseUrl/api/admin/movies${isUpdate ? '/$id' : ''}'),
  );
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({
    'id': id,
    'title': title,
    'code': code,
    'genre': genre,
    'duration': duration,
    'synopsis': synopsis,
    'price': price,
    'imageUrl': imageUrl,
    'status': status,
  });
  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
  final decoded = jsonDecode(response.body);
  return MovieData.fromJson(decoded as Map<String, dynamic>);
}

Future<void> deleteAdminMovie(int id) async {
  final response = await http.delete(
    Uri.parse('$apiBaseUrl/api/admin/movies/$id'),
  );
  if (response.statusCode != 200) {
    throw Exception(
      response.body.isNotEmpty ? response.body : 'Failed to delete movie',
    );
  }
}

Future<List<ScheduleSlot>> fetchAdminSchedules() async {
  final response = await http.get(Uri.parse('$apiBaseUrl/api/admin/schedules'));
  if (response.statusCode != 200) {
    throw Exception('Failed to load admin schedules (${response.statusCode})');
  }
  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Invalid admin schedule response');
  }
  return decoded
      .whereType<Map<String, dynamic>>()
      .map(ScheduleSlot.fromJson)
      .toList();
}

Future<void> saveAdminSchedule({
  int? id,
  required int movieId,
  required String date,
  required String time,
  String hall = '',
}) async {
  final isUpdate = id != null && id > 0;
  final request = http.Request(
    isUpdate ? 'PUT' : 'POST',
    Uri.parse('$apiBaseUrl/api/admin/schedules${isUpdate ? '/$id' : ''}'),
  );
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({
    'movie': {'id': movieId},
    'date': date,
    'time': time,
    'hall': hall,
  });
  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

Future<void> deleteAdminSchedule(int id) async {
  final response = await http.delete(
    Uri.parse('$apiBaseUrl/api/admin/schedules/$id'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to delete schedule');
  }
}

Future<List<SeatModel>> fetchAdminSeats(int scheduleId) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/admin/seats/$scheduleId'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to load admin seats (${response.statusCode})');
  }
  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Invalid admin seat response');
  }
  return decoded
      .whereType<Map<String, dynamic>>()
      .map(SeatModel.fromJson)
      .toList();
}

Future<void> updateSeatStatus(int seatId, bool booked) async {
  final request = http.Request(
    'PUT',
    Uri.parse('$apiBaseUrl/api/admin/seats/$seatId'),
  );
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({'booked': booked});
  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}
