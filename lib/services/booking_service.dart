import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import 'api_service.dart';

class BookingService extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<SalonService> _services = ServiceData.initialServices;
  List<Stylist> _stylists = StylistData.initialStylists;
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<SalonService> get services => _services;
  List<Stylist> get stylists => _stylists;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getServices();
      if (data.isNotEmpty) {
        _services = data
            .map((e) => SalonService.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fall back to hardcoded services on API failure
      _services = ServiceData.initialServices;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStylists() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getStaff();
      if (data.isNotEmpty) {
        _stylists = data
            .map((e) => Stylist.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _stylists = StylistData.initialStylists;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Stylist> getStylistsForService(String serviceName) {
    return _stylists
        .where((s) => s.specialties.any(
              (spec) => spec.toLowerCase() == serviceName.toLowerCase(),
            ))
        .toList();
  }

  SalonService? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Stylist? getStylistById(String id) {
    try {
      return _stylists.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Generate available time slots for a given date and duration.
  List<String> getAvailableTimeSlots({
    required DateTime date,
    required int durationMinutes,
    String openTime = '09:00',
    String closeTime = '21:00',
  }) {
    final slots = <String>[];
    final openParts = openTime.split(':');
    final closeParts = closeTime.split(':');
    var current = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(openParts[0]),
      int.parse(openParts[1]),
    );
    final close = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(closeParts[0]),
      int.parse(closeParts[1]),
    );

    while (current.add(Duration(minutes: durationMinutes)).isBefore(close) ||
        current.add(Duration(minutes: durationMinutes)).isAtSameMomentAs(close)) {
      final hour = current.hour.toString().padLeft(2, '0');
      final minute = current.minute.toString().padLeft(2, '0');
      slots.add('$hour:$minute');
      current = current.add(const Duration(minutes: 30));
    }
    return slots;
  }

  String calculateEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');
    final start = DateTime(
      2024,
      1,
      1,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final end = start.add(Duration(minutes: durationMinutes));
    return '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  Future<Booking?> createBooking({
    required String customerId,
    required String stylistId,
    required String serviceId,
    required DateTime bookingDate,
    required String startTime,
    required int durationMinutes,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final endTime = calculateEndTime(startTime, durationMinutes);
      final response = await _api.createBooking({
        'customerId': customerId,
        'stylistId': stylistId,
        'serviceId': serviceId,
        'bookingDate': bookingDate.toIso8601String().split('T').first,
        'startTime': startTime,
        'endTime': endTime,
        'durationMinutes': durationMinutes,
        'status': 'pending',
        'notesCustomer': notes,
      });

      final booking = Booking.fromJson(
        response['data'] as Map<String, dynamic>? ?? response,
      );
      _bookings.insert(0, booking);
      notifyListeners();
      return booking;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerBookings(String customerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getCustomerBookings(customerId);
      _bookings = data
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    return _updateBookingStatus(bookingId, 'cancelled');
  }

  Future<bool> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required String newStartTime,
    required int durationMinutes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final endTime = calculateEndTime(newStartTime, durationMinutes);
      await _api.updateBooking(bookingId, {
        'bookingDate': newDate.toIso8601String().split('T').first,
        'startTime': newStartTime,
        'endTime': endTime,
        'durationMinutes': durationMinutes,
        'status': 'pending',
      });
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          bookingDate: newDate,
          startTime: newStartTime,
          endTime: endTime,
          durationMinutes: durationMinutes,
          status: 'pending',
        );
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _updateBookingStatus(String bookingId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.updateBooking(bookingId, {'status': status});
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Booking>> loadAdminBookings({
    String? stylistId,
    String? status,
    String? date,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final filters = <String, String>{};
      if (stylistId != null) filters['stylistId'] = stylistId;
      if (status != null) filters['status'] = status;
      if (date != null) filters['date'] = date;

      final data = await _api.getAdminBookings(filters: filters);
      _bookings = data
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
      return _bookings;
    } on ApiException catch (e) {
      _error = e.message;
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adminUpdateBooking(
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _api.updateAdminBooking(bookingId, data);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final updated = await _api.getBooking(bookingId);
        _bookings[index] = Booking.fromJson(
          updated['data'] as Map<String, dynamic>? ?? updated,
        );
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    }
  }
}
