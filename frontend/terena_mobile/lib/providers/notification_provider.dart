import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum NotificationType {
  booking,
  payment,
  reminder,
  cancellation,
  general,
}

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void addBookingNotification({
    required String bookingNumber,
    required String venueName,
    required String date,
    required String time,
    required double totalPrice,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🎉 Booking Confirmed!',
      message: 'Your reservation at $venueName for $date at $time has been confirmed.',
      type: NotificationType.booking,
      timestamp: DateTime.now(),
      metadata: {
        'bookingNumber': bookingNumber,
        'venueName': venueName,
        'date': date,
        'time': time,
        'totalPrice': totalPrice,
      },
    );
    addNotification(notification);
  }

  void addPaymentNotification({
    required String bookingNumber,
    required double amount,
    required String paymentMethod,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '💳 Payment Successful',
      message: 'Payment of ${amount.toStringAsFixed(2)} BAM processed successfully via $paymentMethod.',
      type: NotificationType.payment,
      timestamp: DateTime.now(),
      metadata: {
        'bookingNumber': bookingNumber,
        'amount': amount,
        'paymentMethod': paymentMethod,
      },
    );
    addNotification(notification);
  }

  void addCancellationNotification({
    required String bookingNumber,
    required String venueName,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '❌ Booking Cancelled',
      message: 'Your booking at $venueName has been cancelled.',
      type: NotificationType.cancellation,
      timestamp: DateTime.now(),
      metadata: {
        'bookingNumber': bookingNumber,
        'venueName': venueName,
      },
    );
    addNotification(notification);
  }

  void addReminderNotification({
    required String bookingNumber,
    required String venueName,
    required String date,
    required String time,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '⏰ Upcoming Booking',
      message: 'Reminder: Your reservation at $venueName is tomorrow at $time.',
      type: NotificationType.reminder,
      timestamp: DateTime.now(),
      metadata: {
        'bookingNumber': bookingNumber,
        'venueName': venueName,
        'date': date,
        'time': time,
      },
    );
    addNotification(notification);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
