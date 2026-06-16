class MovieData {
  static const fallbackImageUrl =
      'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=700&q=80';

  final int id;
  final String title;
  final String genre;
  final int duration;
  final String synopsis;
  final double price;
  final String imgUrl;
  final String status;
  final String? code;

  MovieData(
    this.title,
    this.genre,
    this.imgUrl, {
    this.id = 0,
    this.duration = 0,
    this.synopsis = '',
    this.price = 0,
    this.status = 'Now Showing',
    this.code,
  });

  factory MovieData.fromJson(Map<String, dynamic> json) {
    return MovieData(
      (json['title'] ?? 'Untitled Movie').toString(),
      (json['genre'] ?? '-').toString(),
      (json['imageUrl'] ?? json['image_url'] ?? fallbackImageUrl).toString(),
      id: intValue(json['id']),
      duration: intValue(json['duration']),
      synopsis: (json['synopsis'] ?? '').toString(),
      price: doubleValue(json['price']),
      status: (json['status'] ?? json['movieStatus'] ?? 'Now Showing')
          .toString(),
      code: json['code']?.toString(),
    );
  }

  static int intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double doubleValue(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

enum SeatStatus { available, selected, booked }

class SeatModel {
  final int dbId;
  final String id;
  SeatStatus status;
  SeatModel({required this.id, required this.status, this.dbId = 0});

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      dbId: MovieData.intValue(json['id']),
      id: (json['seatNumber'] ?? json['seat_number'] ?? '').toString(),
      status: json['booked'] == true || json['isBooked'] == true
          ? SeatStatus.booked
          : SeatStatus.available,
    );
  }
}

class ScheduleSlot {
  final int id;
  final String time;
  final String? endTime;
  final String date;
  final String hall;
  final String type;
  final Set<String> bookedSeats;

  ScheduleSlot({
    this.id = 0,
    required this.time,
    this.endTime,
    this.date = '',
    required this.hall,
    required this.type,
    required this.bookedSeats,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      id: MovieData.intValue(
        json['scheduleId'] ?? json['schedule_id'] ?? json['id'],
      ),
      time: _formatTime((json['time'] ?? '').toString()),
      endTime: json['endTime'] != null ? _formatTime(json['endTime'].toString()) : null,
      date: (json['date'] ?? '').toString(),
      hall: (json['hall'] ?? json['studio'] ?? 'Hall 1').toString(),
      type: (json['type'] ?? json['format'] ?? 'Reguler 2D').toString(),
      bookedSeats: const <String>{},
    );
  }

  int get totalSeats => 80;
  int get bookedCount => bookedSeats.length;
  int get availableCount => totalSeats - bookedCount;

  String get availabilityLabel {
    if (availableCount < 15) return 'Almost full';
    if (availableCount < 40) return '$availableCount seats left';
    return '$availableCount seats available';
  }

  static String _formatTime(String value) {
    if (value.length >= 5) return value.substring(0, 5);
    return value;
  }
}

class BookedTicket {
  final String movieTitle;
  final String imgUrl;
  final String seats;
  final String date;
  final String time;
  final String hall;
  final double total;
  final String bookingCode;
  final String paymentMethod;

  BookedTicket({
    required this.movieTitle,
    required this.imgUrl,
    required this.seats,
    required this.date,
    required this.time,
    required this.hall,
    required this.total,
    required this.bookingCode,
    required this.paymentMethod,
  });
}

class BookingHistoryItem {
  final String bookingCode;
  final String movieTitle;
  final String showTime;
  final String bookingDate;
  final List<String> seatNumbers;
  final double totalPrice;

  BookingHistoryItem({
    required this.bookingCode,
    required this.movieTitle,
    required this.showTime,
    required this.bookingDate,
    required this.seatNumbers,
    required this.totalPrice,
  });

  factory BookingHistoryItem.fromJson(Map<String, dynamic> json) {
    final seats =
        (json['seatNumbers'] as List?)
            ?.whereType<dynamic>()
            .map((e) => e.toString())
            .toList() ??
        const <String>[];
    return BookingHistoryItem(
      bookingCode: (json['bookingCode'] ?? '').toString(),
      movieTitle: (json['movieTitle'] ?? '').toString(),
      showTime: (json['showTime'] ?? '').toString(),
      bookingDate: (json['bookingDate'] ?? '').toString(),
      seatNumbers: seats,
      totalPrice: MovieData.doubleValue(json['totalPrice']),
    );
  }
}

class ProfileSummary {
  final int moviesWatched;
  final List<BookingHistoryItem> transactionHistory;

  ProfileSummary({
    required this.moviesWatched,
    required this.transactionHistory,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    final history =
        (json['transactionHistory'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(BookingHistoryItem.fromJson)
            .toList() ??
        <BookingHistoryItem>[];
    return ProfileSummary(
      moviesWatched: MovieData.intValue(json['moviesWatched']),
      transactionHistory: history,
    );
  }
}

class PromotionItem {
  final int id;
  final String title;
  final String imageUrl;
  final String linkUrl;
  final bool active;
  final int sortOrder;

  PromotionItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
    required this.active,
    required this.sortOrder,
  });

  factory PromotionItem.fromJson(Map<String, dynamic> json) {
    return PromotionItem(
      id: MovieData.intValue(json['id']),
      title: (json['title'] ?? '').toString(),
      imageUrl:
          (json['imageUrl'] ?? json['image_url'] ?? MovieData.fallbackImageUrl)
              .toString(),
      linkUrl: (json['linkUrl'] ?? json['link_url'] ?? '').toString(),
      active: json['active'] != false,
      sortOrder: MovieData.intValue(json['sortOrder'] ?? json['sort_order']),
    );
  }
}
