// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_otp_request.freezed.dart';
part 'send_otp_request.g.dart';

@freezed
abstract class SendOtpRequest with _$SendOtpRequest {
  const factory SendOtpRequest({@JsonKey(name: 'nis') required String nis}) =
      _SendOtpRequest;

  factory SendOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestFromJson(json);
}
