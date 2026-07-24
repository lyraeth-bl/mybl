// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/sarpras/sarpras.dart';
import '../entities/sarpras_params/sarpras_params.dart';
import '../entities/sarpras_summary/sarpras_summary.dart';
import '../entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';

abstract class SarprasRepository
    implements
        SarprasFetcher<SarprasSummary, Sarpras>,
        SarprasSubmitter<Sarpras, SarprasParams>,
        SarprasUpdater<Sarpras, SarprasParams>,
        SarprasDeleter,
        SarprasTeacherCandidateFetcher<SarprasTeacherCandidate> {}
