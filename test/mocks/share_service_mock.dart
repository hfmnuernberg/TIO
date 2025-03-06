import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/services/share_service.dart';

class ShareServiceMock extends Mock implements ShareService {
  mockShareXFile(ShareResult result) => when(() => shareXFiles(any())).thenAnswer((_) async => Future.value(result));
}
