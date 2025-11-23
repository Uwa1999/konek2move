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
      responseTime: json['responseTime'] ?? '',
      device: json['device'] ?? '',
    );
  }
}

class OtpData {
  final String otpCode;
  final String? jwtToken;

  OtpData({this.otpCode = '', this.jwtToken = ''});

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      otpCode: json['otp_code'] ?? '',
      jwtToken: json['jwt_token'] ?? '',
    );
  }
}
