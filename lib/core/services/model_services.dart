class ModelResponse {
  final ResponseData data;
  final String message;
  final String error;
  final String retCode;
  final String? responseTime;
  final String? device;

  ModelResponse({
    required this.data,
    required this.message,
    required this.error,
    required this.retCode,
    this.responseTime,
    this.device,
  });

  factory ModelResponse.fromJson(Map<String, dynamic> json) {
    return ModelResponse(
      data: ResponseData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
      error: json['error'] ?? '',
      retCode: json['retCode'] ?? '',
      responseTime: json['responseTime'],
      device: json['device'],
    );
  }
}

class ResponseData {
  final Driver driver;
  final String jwtToken;

  ResponseData({required this.driver, required this.jwtToken});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      driver: Driver.fromJson(json['driver'] ?? {}),
      jwtToken: json['jwt_token'] ?? '',
    );
  }
}

class Driver {
  final int id;
  final String driverCode;
  final String firstName;
  final String lastName;
  final String fullName;
  final String gender;
  final String email;
  final String phone;
  final bool emailVerified;
  final String address;
  final String vehicleType;
  final String licenseNumber;
  final String licenseFrontUrl;
  final String licenseBackUrl;
  final String municipalityCode;
  final String status;
  final bool active;
  final String createdAt;
  final String updatedAt;

  Driver({
    required this.id,
    required this.driverCode,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.address,
    required this.vehicleType,
    required this.licenseNumber,
    required this.licenseFrontUrl,
    required this.licenseBackUrl,
    required this.municipalityCode,
    required this.status,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      driverCode: json['driver_code'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      address: json['address'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      licenseFrontUrl: json['license_front_url'] ?? '',
      licenseBackUrl: json['license_back_url'] ?? '',
      municipalityCode: json['municipality_code'] ?? '',
      status: json['status'] ?? '',
      active: json['active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String topic;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? viewedAt;
  final String recipientType;
  final String recipientCode;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.topic,
    required this.createdAt,
    required this.isRead,
    this.viewedAt,
    required this.recipientType,
    required this.recipientCode,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      topic: json['topic'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      viewedAt: json['viewed_at'] != null
          ? DateTime.tryParse(json['viewed_at'])
          : null,
      recipientType: json['recipient_type'] ?? '',
      recipientCode: json['recipient_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'topic': topic,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'viewed_at': viewedAt?.toIso8601String(),
      'recipient_type': recipientType,
      'recipient_code': recipientCode,
    };
  }

  // copyWith method
  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? topic,
    DateTime? createdAt,
    bool? isRead,
    DateTime? viewedAt,
    String? recipientType,
    String? recipientCode,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      topic: topic ?? this.topic,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      viewedAt: viewedAt ?? this.viewedAt,
      recipientType: recipientType ?? this.recipientType,
      recipientCode: recipientCode ?? this.recipientCode,
    );
  }
}

class ModelChatResponse {
  final List<ChatMessage> data;
  final String message;
  final String? error;
  final String retCode;
  final String? responseTime;
  final String? device;

  ModelChatResponse({
    required this.data,
    required this.message,
    this.error,
    required this.retCode,
    this.responseTime,
    this.device,
  });

  factory ModelChatResponse.fromJson(Map<String, dynamic> json) {
    return ModelChatResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
      error: json['error'],
      retCode: json['retCode'] ?? '',
      responseTime: json['responseTime'],
      device: json['device'],
    );
  }
}

class ChatMessage {
  final int id;

  final String senderType;
  final String senderCode;
  final String? message;
  final String? attachmentUrl;
  final String messageType;
  final DateTime createdAt;

  ChatMessage({
    required this.id,

    required this.senderType,
    required this.senderCode,
    this.message,
    this.attachmentUrl,
    required this.messageType,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      senderType: json['sender_type'] ?? '',
      senderCode: json['sender_code'] ?? '',
      message: json['message'],
      attachmentUrl: json['attachment_url'],
      messageType: json['message_type'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}
