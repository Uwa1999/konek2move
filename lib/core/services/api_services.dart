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

  Future<List<NotificationResponse>> getNotifications() async {
    final url = Uri.parse(
      '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/notification/index',
    );
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token") ?? "";
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'] ?? [];
      return data.map((e) => NotificationResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    }
  }

  Stream<Map<String, dynamic>> listenNotifications() async* {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token") ?? "";
    final userCode = prefs.getString("driver_code") ?? "";
    final userType = prefs.getString("user_type") ?? "";
    final url = Uri.parse(
      '${GetDNS.getNotifications()}/api/public/v1/moveapp/notification/listen?user_code=$userCode&user_type=$userType',
    );

    final client = http.Client();

    try {
      final request = http.Request('GET', url);
      request.headers['X-API-KEY'] = GetKEY.getApiKey();
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('SSE failed: HTTP ${response.statusCode}');
      }

      // Decode & split into lines
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        final clean = line.trim();
        if (clean.isEmpty) continue;
        print("📩 RAW SSE LINE: $clean");
        if (!clean.startsWith('data:')) continue;

        final dataPart = clean.substring(5).trim();
        if (dataPart.isEmpty) continue;

        try {
          print("📦 RAW JSON: $dataPart");
          final decoded = json.decode(dataPart);
          if (decoded is Map<String, dynamic>) {
            print("✅ SSE MAP: $decoded");
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
    // required String userCode,
    // required String userType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token") ?? "";
    final url = Uri.parse(
      '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/notification/view',
    );

    final body = json.encode({
      'notification_id': notificationId,
      // 'user_code': userCode,
      // 'user_type': userType,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {
      throw Exception(
        'Failed to mark notification as read: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Map<String, List<String>>> fetchDropdownOptions() async {
    try {
      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/dropdown',
      );
      final http.Response response = await http.get(url);

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

  Future<ModelChatResponse> getChatMessages(int chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token") ?? "";

      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/chat/$chatId/messages',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return ModelChatResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Server returned ${response.statusCode}: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching chat messages: $e");
    }
  }

  Future<ModelResponse> uploadChatImage({
    required int chatId,
    required String orderNo,
    required File file,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString("jwt_token") ?? "";

      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/chat/$chatId/upload',
      );

      var request = http.MultipartRequest('POST', url);

      // Required fields based on your Postman sample
      request.fields['order_no'] = orderNo;
      request.fields['message_type'] = "file";

      // Attach image
      final mimeType = file.path.split('.').last.toLowerCase();
      final imageType = mimeType == "png" ? "png" : "jpeg";

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: http.MediaType("image", imageType),
        ),
      );

      // Add Authorization header
      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return ModelResponse.fromJson(decoded);
      } else {
        throw Exception(
          "Upload failed: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Image upload error: $e");
    }
  }

  Future<ModelResponse> sendChatMessage({
    required int chatId,
    required String orderNo,
    required String message,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token") ?? "";

      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/chat/$chatId/message',
      );

      var request = http.MultipartRequest("POST", url);

      // Fields from Postman screenshot
      request.fields['message'] = message;
      request.fields['order_no'] = orderNo;
      request.fields['message_type'] = "text";

      // Auth header
      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return ModelResponse.fromJson(decodedData);
      } else {
        throw Exception(
          "Chat reply failed: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Chat message error: $e");
    }
  }

  Future<ModelResponse> markChatAsRead(int chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token") ?? "";

      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/chat/$chatId/read',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return ModelResponse.fromJson(decoded);
      } else {
        throw Exception(
          "Failed to mark chat as read: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Chat read error: $e");
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

  Future<OrderResponse> getOrder(int driverId, {String orderNo = ""}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token") ?? "";

      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/orders/index'
        '?driver_id=$driverId&order_no=$orderNo',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return OrderResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Server returned ${response.statusCode}: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching order: $e");
    }
  }

  Future<ModelResponse> updateStatus({
    required int orderId,
    required String status,
    required String lng,
    required String lat,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token") ?? "";

      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/private/v1/moveapp/driver/task/$orderId/status',
      );

      var request = http.MultipartRequest('PUT', url);

      request.fields['status'] = status;
      request.fields['lng'] = lng;
      request.fields['lat'] = lat;

      // Add Authorization header with JWT token
      request.headers['Authorization'] = 'Bearer $token';

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(response.body);
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
