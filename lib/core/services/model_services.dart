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
  final DriverResponse driver;
  final String jwtToken;

  ResponseData({required this.driver, required this.jwtToken});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      driver: DriverResponse.fromJson(json['driver'] ?? {}),
      jwtToken: json['jwt_token'] ?? '',
    );
  }
}

class DriverResponse {
  final int id;
  final String userType;
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
  final String assignedStoreCode;
  final String barangayCode;
  final String status;
  final String memberStatus;
  final bool active;
  final String createdAt;
  final String updatedAt;

  DriverResponse({
    required this.id,
    required this.userType,
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
    required this.assignedStoreCode,
    required this.barangayCode,
    required this.status,
    required this.memberStatus,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    return DriverResponse(
      id: json['id'] ?? 0,
      userType: json['user_type'] ?? '',
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
      assignedStoreCode: json['assigned_store_code'] ?? '',
      barangayCode: json['barangay_code'] ?? '',
      status: json['status'] ?? '',
      memberStatus: json['member_status'] ?? '',
      active: json['active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class NotificationResponse {
  final int id;
  final String title;
  final String body;
  final String topic;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? viewedAt;
  final String recipientType;
  final String recipientCode;

  NotificationResponse({
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

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
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
  NotificationResponse copyWith({
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
    return NotificationResponse(
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
  final List<ChatMessageResponse> data;
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
          .map((e) => ChatMessageResponse.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
      error: json['error'],
      retCode: json['retCode'] ?? '',
      responseTime: json['responseTime'],
      device: json['device'],
    );
  }
}

class ChatMessageResponse {
  final int id;

  final String senderType;
  final String senderCode;
  final String? message;
  final String? attachmentUrl;
  final String messageType;
  final DateTime createdAt;

  ChatMessageResponse({
    required this.id,

    required this.senderType,
    required this.senderCode,
    this.message,
    this.attachmentUrl,
    required this.messageType,
    required this.createdAt,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
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

// ============================================================================
// ORDER RESPONSE MODEL - FULL + CLEAN + MATCHES API
// ============================================================================

class OrderResponse {
  final String responseTime;
  final String device;
  final String retCode;
  final String message;
  final OrderData data;

  OrderResponse({
    required this.responseTime,
    required this.device,
    required this.retCode,
    required this.message,
    required this.data,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      responseTime: json['responseTime'] ?? '',
      device: json['device'] ?? '',
      retCode: json['retCode'] ?? '',
      message: json['message'] ?? '',
      data: OrderData.fromJson(json['data'] ?? {}),
    );
  }
}

// ============================================================================
// DATA WRAPPER
// ============================================================================

class OrderData {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final List<OrderRecord> records;

  OrderData({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.records,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      currentPage: json['currentPage'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      records: (json['records'] as List<dynamic>? ?? [])
          .map((item) => OrderRecord.fromJson(item))
          .toList(),
    );
  }
}

// ============================================================================
// ORDER RECORD (COMPLETE VERSION)
// ============================================================================

class OrderRecord {
  final int id;
  final String orderNo;
  final String supplierCode;
  final String supplierName;
  final String supplierAddress;
  final int customerId;
  final String barangayCode;
  final int assignedDriverId;
  final String status;
  final String statusUpdatedAt;
  final int itemsCount;
  final double totalAmount;
  final String pickupAddress;
  final String deliveryAddress;
  final double pickupLat;
  final double pickupLng;
  final double deliveryLat;
  final double deliveryLng;
  final String contactPhone;
  final bool autoAssigned;
  final String createdAt;
  final String updatedAt;
  final String barangayName;

  final Customer? customer;
  final Driver? driver;

  OrderRecord({
    required this.id,
    required this.orderNo,
    required this.supplierCode,
    required this.supplierName,
    required this.supplierAddress,
    required this.customerId,
    required this.barangayCode,
    required this.assignedDriverId,
    required this.status,
    required this.statusUpdatedAt,
    required this.itemsCount,
    required this.totalAmount,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.contactPhone,
    required this.autoAssigned,
    required this.createdAt,
    required this.updatedAt,
    required this.barangayName,
    this.customer,
    this.driver,
  });

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    return OrderRecord(
      id: json['id'] ?? 0,
      orderNo: json['order_no'] ?? '',
      supplierCode: json['supplier_code'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      supplierAddress: json['supplier_address'] ?? '',
      customerId: json['customer_id'] ?? 0,
      barangayCode: json['barangay_code'] ?? '',
      assignedDriverId: json['assigned_driver_id'] ?? 0,
      status: json['status'] ?? '',
      statusUpdatedAt: json['status_updated_at'] ?? '',
      itemsCount: json['items_count'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      pickupAddress: json['pickup_address'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      pickupLat: (json['pickup_lat'] ?? 0).toDouble(),
      pickupLng: (json['pickup_lng'] ?? 0).toDouble(),
      deliveryLat: (json['delivery_lat'] ?? 0).toDouble(),
      deliveryLng: (json['delivery_lng'] ?? 0).toDouble(),
      contactPhone: json['contact_phone'] ?? '',
      autoAssigned: json['auto_assigned'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      barangayName: json['barangay_name'] ?? '',
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
    );
  }
}

// ============================================================================
// CUSTOMER MODEL
// ============================================================================

class Customer {
  final int id;
  final String code;
  final String name;
  final String phone;

  Customer({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

// ============================================================================
// DRIVER MODEL
// ============================================================================

class Driver {
  final int id;
  final String code;
  final String name;
  final String phone;

  Driver({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
