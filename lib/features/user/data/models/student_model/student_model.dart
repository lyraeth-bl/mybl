// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/student_entity/student_entity.dart';

part 'student_model.freezed.dart';
part 'student_model.g.dart';

@freezed
abstract class StudentModel with _$StudentModel {
  const factory StudentModel({
    @JsonKey(name: "NoKodeSekolah") required String noKodeSekolah,
    @JsonKey(name: "NoKodeKecamatan") required String noKodeKecamatan,
    @JsonKey(name: "NoKodeKabKot") required String noKodeKabupatenKota,
    @JsonKey(name: "NoKodeProvinsi") required String noKodeProvinsi,
    @JsonKey(name: "NIS") required String nis,
    @JsonKey(name: "NISN") String? nisn,
    @JsonKey(name: "Nama") String? nama,
    @JsonKey(name: "NamaPanggilan") required String namaPanggilan,
    @JsonKey(name: "TempLahir") required String tempatLahir,
    @JsonKey(name: "TglLahir") DateTime? tanggalLahir,
    @JsonKey(name: "JenisKelamin") String? jenisKelamin,
    @JsonKey(name: "Agama") String? agama,
    @JsonKey(name: "Kewarganegaraan") required String kewarganegaraan,
    @JsonKey(name: "Alamat") String? alamat,
    @JsonKey(name: "KodePos") required String kodePos,
    @JsonKey(name: "BertempatTinggalPada") required String bertempatTinggalPada,
    @JsonKey(name: "JarakKeSekolah") required String jarakKeSekolah,
    @JsonKey(name: "Telpon") String? noTelepon,
    @JsonKey(name: "DiterimaDiKelas") String? diTerimaDiKelas,
    @JsonKey(name: "NomorKelas") String? nomorKelas,
    @JsonKey(name: "TglDiTerima") required DateTime tanggalDiTerima,
    @JsonKey(name: "Semester") String? semester,
    @JsonKey(name: "NamaSekolahAsal") String? namaSekolahAsal,
    @JsonKey(name: "AlamatSekolahAsal") String? alamatSekolahAsal,
    @JsonKey(name: "TahunIjasah") String? tahunIjazah,
    @JsonKey(name: "NoIjasah") String? noIjazah,
    @JsonKey(name: "TanggalIjazah") required String tanggalIjazah,
    @JsonKey(name: "TahunSkhun") required String tahunSKHUN,
    @JsonKey(name: "NoSkhun") required String noSKHUN,
    @JsonKey(name: "PindahanDariSekolah") required String pindahanDariSekolah,
    @JsonKey(name: "DariTingkat") required String dariTingkat,
    @JsonKey(name: "DiterimaTanggal") required String diTerimaTanggal,
    @JsonKey(name: "NomorSuratKeteranganPindah")
    required String nomorSuratKeteranganPindah,
    @JsonKey(name: "AnakKe") String? anakKe,
    @JsonKey(name: "JumlahSaudaraKandung") required String jumlahSaudaraKandung,
    @JsonKey(name: "JumlahSaudaraTiri") required String jumlahSaudaraTiri,
    @JsonKey(name: "JumlahSaudaraAngkat") required String jumlahSaudaraAngkat,
    @JsonKey(name: "BahasaSeharihariDiRumah")
    required String bahasaSehariHariDiRumah,
    @JsonKey(name: "GolonganDarah") required String golonganDarah,
    @JsonKey(name: "StatKel") required String statusKeluarga,
    @JsonKey(name: "NamaAyah") String? namaAyah,
    @JsonKey(name: "NamaIbu") String? namaIbu,
    @JsonKey(name: "PendidikanTerakhirAyah")
    required String pendidikanTerakhirAyah,
    @JsonKey(name: "PendidikanTerakhirIbu")
    required String pendidikanTerakhirIbu,
    @JsonKey(name: "PekerjaanAyah") String? pekerjaanAyah,
    @JsonKey(name: "PekerjaanIbu") String? pekerjaanIbu,
    @JsonKey(name: "AlamatOrtu") String? alamatOrangTua,
    @JsonKey(name: "TelponOrtu") String? noTeleponOrangTua,
    @JsonKey(name: "NmWali") required String namaWali,
    @JsonKey(name: "AlamatWali") required String alamatWali,
    @JsonKey(name: "HubKelDgnWali") required String hubunganKeluargaDenganWali,
    @JsonKey(name: "PendidikanTerakhirWali")
    required String pendidikanTerakhirWali,
    @JsonKey(name: "TelpWali") required String noTeleponWali,
    @JsonKey(name: "PekerjaanWali") required String pekerjaanWali,
    @JsonKey(name: "Email") String? email,
    @JsonKey(name: "Password") String? passsword,
    @JsonKey(name: "KelasSaatIni") String? kelasSaatIni,
    @JsonKey(name: "NomorKelasSaatIni") String? noKelasSaatIni,
    @JsonKey(name: "TahunLulus") required String tahunLulus,
    @JsonKey(name: "NomorIjazahLulus") required String nomorIjazahLulus,
    @JsonKey(name: "MelanjutkanKeSekolah") required String melanjutkanKeSekolah,
    @JsonKey(name: "PindahSekolahKeSekolah")
    required String pindahSekolahKeSekolah,
    @JsonKey(name: "TingkatKelasYangDitinggalkan")
    required String tingkatKelasYangDiTinggalkan,
    @JsonKey(name: "AlasanKeluarSekolah") required String alasanKeluarSekolah,
    @JsonKey(name: "HariDanTanggalKeluarSekolah")
    required String hariDanTanggalKeluarSekolah,
    @JsonKey(name: "TinggiBadanSemesterGanjil")
    required String tinggiBadanSemesterGanjil,
    @JsonKey(name: "BeratBadanSemesterGanjil")
    required String beratBadanSemesterGanjil,
    @JsonKey(name: "PendengaranSemesterGanjil")
    required String pendengaranSemesterGanjil,
    @JsonKey(name: "PengelihatanSemesterGanjil")
    required String penglihatanSemesterGanjil,
    @JsonKey(name: "GigiSemesterGanjil") required String gigiSemesterGanjil,
    @JsonKey(name: "TinggiBadanSemesterGenap")
    required String tinggiBadanSemesterGenap,
    @JsonKey(name: "BeratBadanSemesterGenap")
    required String beratBadanSemesterGenap,
    @JsonKey(name: "PendengaranSemesterGenap")
    required String pendengaranSemesterGenap,
    @JsonKey(name: "PengelihatanSemesterGenap")
    required String penglihatanSemesterGenap,
    @JsonKey(name: "GigiSemesterGenap") required String gigiSemesterGenap,
    @JsonKey(name: "JenisPrestasiSainsSeniAtauOlahraga")
    required String jenisPrestasiSainsSeniAtauOlahraga,
    @JsonKey(
      name: "TingkatPrestasiSekolahKecamatanKabupatenProvinsiAtauNasional",
    )
    required String
    tingkatPrestasiSekolahKecamatanKabupatenProvinsiAtauNasional,
    @JsonKey(name: "NamaPrestasiLombaCerdasCermat")
    required String namaPrestasiLombaCerdasCermat,
    @JsonKey(name: "TahunPrestasiYangPernahDiraih")
    required String tahunPrestasiYangPernahDiraih,
    @JsonKey(
      name: "PenyelenggaraNamaPenyelenggaraAtauPanitiaKegiatanDariPrestasi",
    )
    required String
    penyelenggaraNamaPenyelenggaraAtauPanitiaKegiatanDariPrestasi,
    @JsonKey(name: "PeringkatAngkaPeringkatPrestasiYangPernahDiraih")
    required String peringkatAngkaPeringkatPrestasiYangPernahDiraih,
    @JsonKey(name: "JenisBeasiswaAnakBerprestasiAnakUnggulUnggulanAtauLainlain")
    required String jenisBeasiswaAnakBerprestasiAnakUnggulUnggulanAtauLainlain,
    @JsonKey(name: "KeteranganBeasiswaMuridBerprestasiTahun2022")
    required String keteranganBeasiswaMuridBerprestasiTahun2022,
    @JsonKey(name: "TahunMulaiTahunMulaiDiterimanyaBeasiswaOlehPesertaDidik")
    required String tahunMulaiTahunMulaiDiterimanyaBeasiswaOlehPesertaDidik,
    @JsonKey(
      name: "TahunSelesaiTahunSelesaiDiterimanyaBeasiswaOlehPesertaDidik",
    )
    required String tahunSelesaiTahunSelesaiDiterimanyaBeasiswaOlehPesertaDidik,
    @JsonKey(name: "SetelahSelesaiPendidikanMeninggalkanSekolah")
    required String setelahSelesaiPendidikanMeninggalkanSekolah,
    @JsonKey(name: "KeluarKarena") required String keluarKarena,
    @JsonKey(name: "TanggalKeluar") required String tanggalKeluar,
    @JsonKey(name: "AkhirPendidikan") required String akhirPendidikan,
    @JsonKey(name: "TamatBelajar") required String tamatBelajar,
    @JsonKey(name: "NomorIjazah") required String nomorIjazah,
    @JsonKey(name: "Aktif") String? aktif,
    @JsonKey(name: "StatNaik") required String statusNaik,
    @JsonKey(name: "UnameOrtu") required String usernameOrangTua,
    @JsonKey(name: "OrtuPass") required String passwordOrangTua,
    @JsonKey(name: "StatUjian") String? statusUjian,
    @JsonKey(name: "foto") String? profileImageUrl,
    @JsonKey(name: "unit") String? unit,
  }) = _StudentModel;

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);
}

extension StudentModelMapper on StudentModel {
  StudentEntity toEntity() => StudentEntity(
    agama: agama,
    aktif: aktif,
    alamat: alamat,
    alamatOrangTua: alamatOrangTua,
    alamatSekolahAsal: alamatSekolahAsal,
    anakKe: anakKe,
    diTerimaDiKelas: diTerimaDiKelas,
    email: email,
    jenisKelamin: jenisKelamin,
    kelasSaatIni: kelasSaatIni,
    nama: nama,
    namaAyah: namaAyah,
    namaIbu: namaIbu,
    namaSekolahAsal: namaSekolahAsal,
    nisn: nisn,
    noIjazah: noIjazah,
    noKelasSaatIni: noKelasSaatIni,
    nomorKelas: nomorKelas,
    noTelepon: noTelepon,
    noTeleponOrangTua: noTeleponOrangTua,
    passsword: passsword,
    pekerjaanAyah: pekerjaanAyah,
    pekerjaanIbu: pekerjaanIbu,
    profileImageUrl: profileImageUrl,
    semester: semester,
    statusUjian: statusUjian,
    tahunIjazah: tahunIjazah,
    tanggalLahir: tanggalLahir,
    unit: unit,
    noKodeSekolah: noKodeSekolah,
    noKodeKecamatan: noKodeKecamatan,
    noKodeKabupatenKota: noKodeKabupatenKota,
    noKodeProvinsi: noKodeProvinsi,
    nis: nis,
    namaPanggilan: namaPanggilan,
    tempatLahir: tempatLahir,
    kewarganegaraan: kewarganegaraan,
    kodePos: kodePos,
    bertempatTinggalPada: bertempatTinggalPada,
    jarakKeSekolah: jarakKeSekolah,
    tanggalDiTerima: tanggalDiTerima,
    tanggalIjazah: tanggalIjazah,
    tahunSKHUN: tahunSKHUN,
    noSKHUN: noSKHUN,
    pindahanDariSekolah: pindahanDariSekolah,
    dariTingkat: dariTingkat,
    diTerimaTanggal: diTerimaTanggal,
    nomorSuratKeteranganPindah: nomorSuratKeteranganPindah,
    jumlahSaudaraKandung: jumlahSaudaraKandung,
    jumlahSaudaraTiri: jumlahSaudaraTiri,
    jumlahSaudaraAngkat: jumlahSaudaraAngkat,
    bahasaSehariHariDiRumah: bahasaSehariHariDiRumah,
    golonganDarah: golonganDarah,
    statusKeluarga: statusKeluarga,
    pendidikanTerakhirAyah: pendidikanTerakhirAyah,
    pendidikanTerakhirIbu: pendidikanTerakhirIbu,
    namaWali: namaWali,
    alamatWali: alamatWali,
    hubunganKeluargaDenganWali: hubunganKeluargaDenganWali,
    pendidikanTerakhirWali: pendidikanTerakhirWali,
    noTeleponWali: noTeleponWali,
    pekerjaanWali: pekerjaanWali,
    tahunLulus: tahunLulus,
    nomorIjazahLulus: nomorIjazahLulus,
    melanjutkanKeSekolah: melanjutkanKeSekolah,
    pindahSekolahKeSekolah: pindahSekolahKeSekolah,
    tingkatKelasYangDiTinggalkan: tingkatKelasYangDiTinggalkan,
    alasanKeluarSekolah: alasanKeluarSekolah,
    hariDanTanggalKeluarSekolah: hariDanTanggalKeluarSekolah,
    tinggiBadanSemesterGanjil: tinggiBadanSemesterGanjil,
    beratBadanSemesterGanjil: beratBadanSemesterGanjil,
    pendengaranSemesterGanjil: pendengaranSemesterGanjil,
    penglihatanSemesterGanjil: penglihatanSemesterGanjil,
    gigiSemesterGanjil: gigiSemesterGanjil,
    tinggiBadanSemesterGenap: tinggiBadanSemesterGenap,
    beratBadanSemesterGenap: beratBadanSemesterGenap,
    pendengaranSemesterGenap: pendengaranSemesterGenap,
    penglihatanSemesterGenap: penglihatanSemesterGenap,
    gigiSemesterGenap: gigiSemesterGenap,
    jenisPrestasiSainsSeniAtauOlahraga: jenisPrestasiSainsSeniAtauOlahraga,
    tingkatPrestasiSekolahKecamatanKabupatenProvinsiAtauNasional:
        tingkatPrestasiSekolahKecamatanKabupatenProvinsiAtauNasional,
    namaPrestasiLombaCerdasCermat: namaPrestasiLombaCerdasCermat,
    tahunPrestasiYangPernahDiraih: tahunPrestasiYangPernahDiraih,
    penyelenggaraNamaPenyelenggaraAtauPanitiaKegiatanDariPrestasi:
        penyelenggaraNamaPenyelenggaraAtauPanitiaKegiatanDariPrestasi,
    peringkatAngkaPeringkatPrestasiYangPernahDiraih:
        peringkatAngkaPeringkatPrestasiYangPernahDiraih,
    jenisBeasiswaAnakBerprestasiAnakUnggulUnggulanAtauLainlain:
        jenisBeasiswaAnakBerprestasiAnakUnggulUnggulanAtauLainlain,
    keteranganBeasiswaMuridBerprestasiTahun2022:
        keteranganBeasiswaMuridBerprestasiTahun2022,
    tahunMulaiTahunMulaiDiterimanyaBeasiswaOlehPesertaDidik:
        tahunMulaiTahunMulaiDiterimanyaBeasiswaOlehPesertaDidik,
    tahunSelesaiTahunSelesaiDiterimanyaBeasiswaOlehPesertaDidik:
        tahunSelesaiTahunSelesaiDiterimanyaBeasiswaOlehPesertaDidik,
    setelahSelesaiPendidikanMeninggalkanSekolah:
        setelahSelesaiPendidikanMeninggalkanSekolah,
    keluarKarena: keluarKarena,
    tanggalKeluar: tanggalKeluar,
    akhirPendidikan: akhirPendidikan,
    tamatBelajar: tamatBelajar,
    nomorIjazah: nomorIjazah,
    statusNaik: statusNaik,
    usernameOrangTua: usernameOrangTua,
    passwordOrangTua: passwordOrangTua,
  );
}
