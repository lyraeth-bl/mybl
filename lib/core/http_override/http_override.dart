import 'dart:io';

/// Class jagoan buat bypass urusan sertifikat HTTP yang rewel.
///
/// Pas lagi development, kadang kita butuh akses ke API yang sertifikatnya
/// belum valid atau self-signed. Nah, [MyHttpOverrides] ini tugasnya jadi
/// "si paling santai" yang ngebolehin semua koneksi lewat tanpa drama sertifikat.
class MyHttpOverrides extends HttpOverrides {
  @override
  /// Bikin [HttpClient] kustom yang nggak baperan sama sertifikat.
  ///
  /// Di sini kita set [badCertificateCallback] biar selalu return `true`.
  /// Artinya, mau sertifikatnya bener atau abal-abal, gaspol aja terus.
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
