// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../domain/entities/discipline.dart';

class DisciplineItem {
  const DisciplineItem({
    required this.description,
    required this.point,
    required this.date,
    required this.schoolSession,
    required this.semester,
    required this.teacherName,
    required this.isMerit,
  });

  factory DisciplineItem.fromMerit(MeritEntity merit) {
    return DisciplineItem(
      description: merit.description,
      point: merit.point,
      date: merit.date,
      schoolSession: merit.schoolSession,
      semester: merit.semester,
      teacherName: merit.teacherName,
      isMerit: true,
    );
  }

  factory DisciplineItem.fromDemerit(DemeritEntity demerit) {
    return DisciplineItem(
      description: demerit.description,
      point: demerit.point,
      date: demerit.date,
      schoolSession: demerit.schoolSession,
      semester: demerit.semester,
      teacherName: demerit.teacherName,
      isMerit: false,
    );
  }

  factory DisciplineItem.placeholder(int index) {
    return DisciplineItem(
      description: 'Discipline activity',
      point: 0,
      date: DateTime(2026),
      schoolSession: '',
      semester: '',
      teacherName: 'Teacher',
      isMerit: index.isEven,
    );
  }

  final String description;
  final int point;
  final DateTime date;
  final String schoolSession;
  final String semester;
  final String teacherName;
  final bool isMerit;
}
