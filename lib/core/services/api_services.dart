import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dns_services.dart';
import 'model_services.dart';

class ApiServices {
  Future<Map<String, List<String>>> fetchDropdownOptions() async {
    try {
      final Uri url = Uri.parse(
        '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/dropdown/',
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

      // Add files
      request.files.add(
        await http.MultipartFile.fromPath('license_front', licenseFront.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('license_back', licenseBack.path),
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

// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:smooth_chucker/smooth_chucker.dart';
// import 'dns_services.dart';
// import 'model_services.dart';
//
// class ApiServices {
//   // Wrap the http.Client with SmoothChuckerHttpClient
//   final SmoothChuckerHttpClient _client = SmoothChuckerHttpClient(
//     http.Client(),
//   );
//
//   ApiServices() {
//     // Optional: Initialize Smooth Chucker globally, if not already initialized
//     // SmoothChucker.initialize(Overlay.of(context)!);
//   }
//
//   Future<Map<String, List<String>>> fetchDropdownOptions() async {
//     try {
//       final Uri url = Uri.parse(
//         '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/dropdown/',
//       );
//
//       final http.Response response = await _client.get(url);
//
//       print('Dropdown Response: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> decodedData = jsonDecode(response.body);
//         final Map<String, dynamic> data = decodedData['data'];
//
//         Map<String, List<String>> dropdowns = {};
//         data.forEach((key, value) {
//           dropdowns[key] = List<String>.from(value);
//         });
//
//         return dropdowns;
//       } else {
//         throw Exception(
//           'Server returned ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
//
//   Future<ModelResponse> emailVerification(String email) async {
//     try {
//       final Uri url = Uri.parse(
//         '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/auth/request-signup-otp',
//       );
//
//       final http.Response response = await _client.post(
//         url,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode({"email": email}),
//       );
//
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> decodedData = jsonDecode(response.body);
//         return ModelResponse.fromJson(decodedData);
//       } else {
//         throw Exception(
//           'Server returned ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
//
//   Future<ModelResponse> emailOTPVerification(String otp) async {
//     try {
//       final Uri url = Uri.parse(
//         '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/auth/verify-signup-otp',
//       );
//
//       final http.Response response = await _client.post(
//         url,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode({"otp": otp}),
//       );
//
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> decodedData = jsonDecode(response.body);
//         return ModelResponse.fromJson(decodedData);
//       } else {
//         throw Exception(
//           'Server returned ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
//
//   Future<ModelResponse> signup({
//     required String firstName,
//     String? middleName,
//     required String lastName,
//     String? suffix,
//     required String gender,
//     required String email,
//     required String phone,
//     required String address,
//     required String password,
//     required String vehicleType,
//     required String licenseNumber,
//     required File licenseFront,
//     required File licenseBack,
//   }) async {
//     try {
//       final Uri url = Uri.parse(
//         '${GetDNS.getOttokonekHestia()}/api/public/v1/moveapp/auth/signup',
//       );
//
//       var request = http.MultipartRequest('POST', url);
//
//       // Add text fields
//       request.fields['first_name'] = firstName;
//       if (middleName != null) request.fields['middle_name'] = middleName;
//       request.fields['last_name'] = lastName;
//       if (suffix != null) request.fields['suffix'] = suffix;
//       request.fields['gender'] = gender;
//       request.fields['email'] = email;
//       request.fields['phone'] = phone;
//       request.fields['address'] = address;
//       request.fields['password'] = password;
//       request.fields['vehicle_type'] = vehicleType;
//       request.fields['license_number'] = licenseNumber;
//
//       // Add files
//       request.files.add(
//         await http.MultipartFile.fromPath('license_front', licenseFront.path),
//       );
//       request.files.add(
//         await http.MultipartFile.fromPath('license_back', licenseBack.path),
//       );
//
//       // Send request via SmoothChuckerHttpClient
//       final streamedResponse = await _client.send(request);
//       final response = await http.Response.fromStream(streamedResponse);
//
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> decodedData = jsonDecode(response.body);
//         return ModelResponse.fromJson(decodedData);
//       } else {
//         throw Exception(
//           'Server returned ${response.statusCode}: ${response.body}',
//         );
//       }
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
// }
