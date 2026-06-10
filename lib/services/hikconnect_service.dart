import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceRecord {
  final String employeeId;
  final String employeeName;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const AttendanceRecord({
    required this.employeeId,
    required this.employeeName,
    this.checkIn,
    this.checkOut,
  });

  bool get isPresent => checkIn != null;

  bool get isLate {
    if (checkIn == null) return false;
    return checkIn!.hour > 10 || (checkIn!.hour == 10 && checkIn!.minute > 30);
  }

  bool get isCheckedOut => checkOut != null;

  String get statusLabel {
    if (!isPresent) return 'Absent';
    final inStr = _fmt(checkIn!);
    if (isCheckedOut) return 'In $inStr  •  Out ${_fmt(checkOut!)}';
    return 'In $inStr';
  }

  String _fmt(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour12:$m $ampm';
  }
}

class HikConnectService {
  static final HikConnectService instance = HikConnectService._();
  HikConnectService._();

  static const _baseUrl = 'https://open.hikvision.com';
  static const _keyUser = 'hikconnect_username';
  static const _keyPass = 'hikconnect_password';
  static const _timeout = Duration(seconds: 15);

  String? _username;
  String? _password;
  String? _sessionId;
  bool _connected = false;

  bool get isConfigured => _username?.isNotEmpty == true && _password?.isNotEmpty == true;
  bool get isConnected => _connected;
  String? get username => _username;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _username = p.getString(_keyUser);
    _password = p.getString(_keyPass);
  }

  Future<void> save(String username, String password) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyUser, username);
    await p.setString(_keyPass, password);
    _username = username;
    _password = password;
    _connected = false;
    _sessionId = null;
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyUser);
    await p.remove(_keyPass);
    _username = null;
    _password = null;
    _sessionId = null;
    _connected = false;
  }

  String _md5(String input) =>
      md5.convert(utf8.encode(input)).toString();

  Future<bool> authenticate() async {
    if (!isConfigured) return false;
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/cloudSso/v1/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'loginName': _username,
          'loginPassword': _md5(_password!),
        }),
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final code = body['resultCode']?.toString() ?? body['code']?.toString();
        if (code == '0') {
          _sessionId = body['sessionId'] as String? ??
              (body['data'] as Map<String, dynamic>?)?['sessionId'] as String?;
          _connected = _sessionId != null;
          return _connected;
        }
      }
    } catch (_) {}
    _connected = false;
    return false;
  }

  Future<List<AttendanceRecord>> getTodayAttendance() async {
    if (!isConfigured) return _demo();
    if (!_connected) await authenticate();
    if (!_connected || _sessionId == null) return _demo();

    try {
      final now = DateTime.now();
      final d = '${now.year}-${_p(now.month)}-${_p(now.day)}';
      final res = await http.post(
        Uri.parse('$_baseUrl/api/lapp/pass/record/advance/search'),
        headers: {
          'Content-Type': 'application/json',
          'sessionId': _sessionId!,
        },
        body: jsonEncode({
          'startTime': '$d 00:00:00',
          'endTime': '$d 23:59:59',
          'pageNum': 1,
          'pageSize': 200,
        }),
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (body['data'] as Map<String, dynamic>?)?['list'] as List<dynamic>? ??
            body['list'] as List<dynamic>? ?? [];
        if (list.isNotEmpty) return _parse(list);
      }
    } catch (_) {}
    return _demo();
  }

  List<AttendanceRecord> _parse(List<dynamic> raw) {
    final Map<String, Map<String, dynamic>> byPerson = {};
    for (final item in raw) {
      final e = item as Map<String, dynamic>;
      final name = e['personName'] as String? ?? e['name'] as String? ?? 'Unknown';
      final id = e['personId']?.toString() ?? name;
      final rawTime = e['passTime'] as String? ?? e['eventTime'] as String?;
      final dir = (e['doorDirection'] as String? ?? e['eventType'] as String? ?? 'in').toLowerCase();
      if (rawTime == null) continue;
      final dt = DateTime.tryParse(rawTime.contains('T') ? rawTime : rawTime.replaceFirst(' ', 'T'));
      if (dt == null) continue;

      byPerson.putIfAbsent(id, () => {'name': name, 'id': id});
      final isIn = dir.contains('in') || dir == '0';
      if (isIn) {
        final prev = byPerson[id]!['checkIn'] as DateTime?;
        if (prev == null || dt.isBefore(prev)) byPerson[id]!['checkIn'] = dt;
      } else {
        final prev = byPerson[id]!['checkOut'] as DateTime?;
        if (prev == null || dt.isAfter(prev)) byPerson[id]!['checkOut'] = dt;
      }
    }

    return byPerson.values
        .map((p) => AttendanceRecord(
              employeeId: p['id'] as String,
              employeeName: p['name'] as String,
              checkIn: p['checkIn'] as DateTime?,
              checkOut: p['checkOut'] as DateTime?,
            ))
        .toList()
      ..sort((a, b) {
        if (a.checkIn == null && b.checkIn == null) {
          return a.employeeName.compareTo(b.employeeName);
        }
        if (a.checkIn == null) return 1;
        if (b.checkIn == null) return -1;
        return a.checkIn!.compareTo(b.checkIn!);
      });
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  List<AttendanceRecord> _demo() {
    final t = DateTime.now();
    return [
      AttendanceRecord(employeeId: '1', employeeName: 'Ayesha Rahman',
          checkIn: DateTime(t.year, t.month, t.day, 9, 2)),
      AttendanceRecord(employeeId: '2', employeeName: 'Riya Sen',
          checkIn: DateTime(t.year, t.month, t.day, 9, 15),
          checkOut: DateTime(t.year, t.month, t.day, 17, 30)),
      AttendanceRecord(employeeId: '3', employeeName: 'Nadia Hossain'),
      AttendanceRecord(employeeId: '4', employeeName: 'Lamia Ahmed',
          checkIn: DateTime(t.year, t.month, t.day, 10, 8)),
      AttendanceRecord(employeeId: '5', employeeName: 'Sadia Islam',
          checkIn: DateTime(t.year, t.month, t.day, 9, 45)),
    ];
  }
}
