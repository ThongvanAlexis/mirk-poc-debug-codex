// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import '../../config/constants.dart';
import '../location/geo_fix.dart';
import 'reveal_disc.dart';

/// In-memory reveal state for the renderer POC.
///
/// This deliberately has no persistence or permission coupling. It starts with
/// seeded Melun reveal discs so the fog renderer has visible holes before the
/// Phase 3 live foreground location flow exists.
typedef RevealDiscRepositoryListener = void Function();

class RevealDiscRepository {
  RevealDiscRepository({Iterable<RevealDisc>? seedDiscs}) : _discs = List<RevealDisc>.of(seedDiscs ?? seededMelunDiscs);

  static List<RevealDisc> get seededMelunDiscs {
    final fixedAtUtc = DateTime.utc(2026, 5, 2);
    return <RevealDisc>[
      RevealDisc(
        id: 'seed_melun_center',
        sessionId: _pocSessionId,
        lat: kPocInitialLatitude,
        lon: kPocInitialLongitude,
        radiusMeters: kPocRevealDiscRadiusMeters,
        fixedAtUtc: fixedAtUtc,
      ),
      RevealDisc(
        id: 'seed_melun_north_east',
        sessionId: _pocSessionId,
        lat: 48.5403,
        lon: 2.6564,
        radiusMeters: kPocRevealDiscRadiusMeters,
        fixedAtUtc: fixedAtUtc,
      ),
    ];
  }

  final List<RevealDisc> _discs;
  final List<RevealDiscRepositoryListener> _listeners = <RevealDiscRepositoryListener>[];
  int _acceptedFixCount = 0;
  bool _disposed = false;

  List<RevealDisc> snapshot() => List<RevealDisc>.unmodifiable(_discs);

  void addListener(RevealDiscRepositoryListener listener) {
    if (_disposed) throw StateError('RevealDiscRepository has been disposed');
    _listeners.add(listener);
  }

  void removeListener(RevealDiscRepositoryListener listener) {
    _listeners.remove(listener);
  }

  void append(RevealDisc disc) {
    if (_disposed) throw StateError('RevealDiscRepository has been disposed');
    _discs.add(disc);
    for (final listener in List<RevealDiscRepositoryListener>.of(_listeners)) {
      listener();
    }
  }

  bool appendFix(GeoFix fix) {
    if (!fix.isAcceptedForReveal) return false;
    _acceptedFixCount++;
    append(
      RevealDisc(
        id: 'rvd_${fix.fixedAtUtc.toUtc().microsecondsSinceEpoch}_$_acceptedFixCount',
        sessionId: _pocSessionId,
        lat: fix.latitude,
        lon: fix.longitude,
        radiusMeters: kPocRevealDiscRadiusMeters,
        fixedAtUtc: fix.fixedAtUtc.toUtc(),
      ),
    );
    return true;
  }

  void dispose() {
    _disposed = true;
    _listeners.clear();
  }
}

const String _pocSessionId = 'poc';
