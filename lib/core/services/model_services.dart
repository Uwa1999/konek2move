class ModelResponse {
  final OtpData data;
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
      data: OtpData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
      error: json['error'] ?? '',
      retCode: json['retCode'] ?? '',
      responseTime: json['responseTime'] as String?,
      device: json['device'] as String?,
    );
  }
}

class OtpData {
  final String otpCode;

  OtpData({this.otpCode = ''});

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(otpCode: json['otp_code'] ?? '');
  }
}
