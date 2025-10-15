import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/domain/audio/markers.dart';

import '../../../utils/test_context.dart';

void main() {
  late Markers handler;
  late TestContext context;
  late List<double> triggered;

  setUp(() {
    context = TestContext();
    handler = Markers(context.audioSystem);
    triggered = <double>[];
  });

  test('does not trigger without markers', () {
    handler.checkMarkers(previousPosition: 0, currentPosition: 0, markers: [], onPeep: triggered.add);

    expect(triggered.length, 0);
  });

  test('triggers marker at 0.0 when starting near 0.0', () {
    handler.checkMarkers(previousPosition: 0, currentPosition: 0, markers: [0.0], onPeep: triggered.add);

    expect(triggered, contains(0.0));
    expect(triggered.length, 1);
  });

  test('triggers when crossing marker', () {
    handler.checkMarkers(previousPosition: 0.09, currentPosition: 0.11, markers: [0.10], onPeep: triggered.add);

    expect(triggered, contains(0.10));
    expect(triggered.length, 1);
  });

  test('triggers when close enough to marker (within epsilon)', () {
    handler.checkMarkers(previousPosition: 0.08, currentPosition: 0.09, markers: [0.10], onPeep: triggered.add);

    expect(triggered, contains(0.10));
    expect(triggered.length, 1);
  });

  test('does not trigger twice for same marker', () {
    handler.checkMarkers(previousPosition: 0.09, currentPosition: 0.11, markers: [0.10], onPeep: triggered.add);
    handler.checkMarkers(previousPosition: 0.11, currentPosition: 0.12, markers: [0.10], onPeep: triggered.add);

    expect(triggered, contains(0.10));
    expect(triggered.length, 1);
  });

  test('ignores duplicate markers in list', () {
    handler.checkMarkers(previousPosition: 0.09, currentPosition: 0.11, markers: [0.10, 0.10], onPeep: triggered.add);

    expect(triggered.length, 1);
    expect(triggered, contains(0.10));
  });
}
