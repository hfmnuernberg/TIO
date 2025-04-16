import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/services/share_plus.dart';

class SharePlusMock extends Mock implements SharePlus {
  mockShareXFile(ShareResult result) => when(() => shareXFiles(any())).thenAnswer((_) async => Future.value(result));
}
