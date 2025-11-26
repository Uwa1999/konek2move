import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dns_services.dart';
import 'model_services.dart';

class ApiServices {
  Future<ModelResponse> updateLocation({
    required String lng,
    required String lat,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token") ?? "";

      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/driver/location',
      );

      var request = http.MultipartRequest('PUT', url);

      request.fields['lng'] = lng;
      request.fields['lat'] = lat;

      // Add Authorization header with JWT token
      request.headers['Authorization'] = 'Bearer $token';

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return ModelResponse.fromJson(decodedData);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Future<ModelResponse> refuseOrder({required String reason}) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("jwt_token") ?? "";
  //     final driverId = prefs.getInt("id");
  //
  //     final Uri url = Uri.parse(
  //       '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/driver/task/$driverId/refuse',
  //     );
  //
  //     var request = http.MultipartRequest('PUT', url);
  //
  //     request.fields['reason'] = reason;
  //
  //     // Add Authorization header with JWT token
  //     request.headers['Authorization'] = 'Bearer $token';
  //
  //     // Send request
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> decodedData = jsonDecode(response.body);
  //       return ModelResponse.fromJson(decodedData);
  //     } else {
  //       throw Exception(
  //         'Server returned ${response.statusCode}: ${response.body}',
  //       );
  //     }
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }

  Future<List<NotificationModel>> getNotifications({
    required String userCode,
    required String userType,
  }) async {
    final url = Uri.parse(
      '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/notification/index?user_code=$userCode&user_type=$userType',
    );
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'] ?? [];
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    }
  }

  Stream<Map<String, dynamic>> listenNotifications({
    required String userCode,
    required String userType,
  }) async* {
    final url = Uri.parse(
      '${GetDNS.getNotifications()}/api/public/v1/moveapp/notification/listen'
      '?user_code=$userCode&user_type=$userType',
    );

    final client = http.Client();

    try {
      final request = http.Request('GET', url);
      request.headers['X-API-KEY'] = GetKEY.getApiKey();
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      print("🔌 Connecting to SSE...");

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('SSE failed: HTTP ${response.statusCode}');
      }

      print("✅ SSE connected!");

      // Decode & split into lines
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        final clean = line.trim();
        if (clean.isEmpty) continue;

        print("📨 SSE raw line: $clean");

        if (!clean.startsWith('data:')) continue;

        final dataPart = clean.substring(5).trim();
        if (dataPart.isEmpty) continue;

        print("📦 SSE data payload: $dataPart");

        try {
          final decoded = json.decode(dataPart);
          if (decoded is Map<String, dynamic>) {
            yield decoded;
          } else {
            print("⚠️ SSE JSON is not a Map");
          }
        } catch (e) {
          print("❌ SSE decode error: $e");
        }
      }
    } catch (e) {
      print("❌ SSE error: $e");
    } finally {
      // Do NOT close the client immediately — it breaks the stream
      // but if error or completed, clean up
      client.close();
    }
  }

  Future<void> markNotificationAsRead({
    required int notificationId,
    required String userCode,
    required String userType,
  }) async {
    final url = Uri.parse(
      '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/notification/view',
    );

    final body = json.encode({
      'notification_id': notificationId,
      'user_code': userCode,
      'user_type': userType,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {
      throw Exception(
        'Failed to mark notification as read: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Future<Map<String, Map<String, String>>> fetchDropdownLocationOptions({
  //   required String regionCode,
  //   required String provinceCode,
  //   required String municipalityCode,
  // }) async {
  //   try {
  //     final Uri url = Uri.parse(
  //       '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/dropdown/location'
  //       '?region_code=$regionCode&province_code=$provinceCode&municipality_code=$municipalityCode',
  //     );
  //     final http.Response response = await http.get(url);
  //
  //     print('Dropdown Response: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> decodedData = jsonDecode(response.body);
  //       final Map<String, dynamic> data = decodedData['data'];
  //
  //       // Convert each list in data to Map<code, name>
  //       Map<String, Map<String, String>> dropdowns = {};
  //       data.forEach((key, value) {
  //         final List items = value as List;
  //         dropdowns[key] = {
  //           for (var item in items)
  //             item['code'] as String: item['name'] as String,
  //         };
  //       });
  //
  //       return dropdowns;
  //     } else {
  //       throw Exception(
  //         'Server returned ${response.statusCode}: ${response.body}',
  //       );
  //     }
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }

  Future<Map<String, List<String>>> fetchDropdownOptions() async {
    try {
      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/dropdown',
      );
      final http.Response response = await http.get(url);

      print('Dropdown Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final Map<String, dynamic> data = decodedData['data'];

        // Convert each list in data to List<String>
        Map<String, List<String>> dropdowns = {};
        data.forEach((key, value) {
          dropdowns[key] = List<String>.from(value);
        });

        return dropdowns;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<ModelResponse> emailVerification(String email) async {
    try {
      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/auth/request-signup-otp',
      );
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": email}),
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return ModelResponse.fromJson(decodedData);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<ModelResponse> emailOTPVerification(String otp) async {
    try {
      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/auth/verify-signup-otp',
      );
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"otp": otp}),
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return ModelResponse.fromJson(decodedData);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<ModelResponse> signin(String email, String password) async {
    try {
      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/auth/signin',
      );
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return ModelResponse.fromJson(decodedData);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<ModelResponse> signup({
    required String firstName,
    String? middleName,
    required String lastName,
    String? suffix,
    required String gender,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String vehicleType,
    required String licenseNumber,
    required File licenseFront,
    required File licenseBack,
  }) async {
    try {
      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/auth/signup',
      );

      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['first_name'] = firstName;
      if (middleName != null) request.fields['middle_name'] = middleName;
      request.fields['last_name'] = lastName;
      if (suffix != null) request.fields['suffix'] = suffix;
      request.fields['gender'] = gender;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['password'] = password;
      request.fields['vehicle_type'] = vehicleType;
      request.fields['license_number'] = licenseNumber;
      request.files.add(
        await http.MultipartFile.fromPath(
          'license_front',
          licenseFront.path,
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'license_back',
          licenseBack.path,
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return ModelResponse.fromJson(decodedData);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
