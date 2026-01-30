part of '../../camera.dart';

class OutletQrDtoData {
  final String rcs;
  final int? outletId;
  final String? sessionId;
  final String? type;

  const OutletQrDtoData({
    required this.rcs,
    this.outletId,
    this.sessionId,
    this.type,
  });

  static OutletQrDtoData fromJson(Map<String, dynamic> json) {
    return OutletQrDtoData(
      rcs: json['outletRcs'],
      outletId: json['tmrId'],
      sessionId: json['sessionId'],
      type: json['actionTypes'],
    );
  }
}