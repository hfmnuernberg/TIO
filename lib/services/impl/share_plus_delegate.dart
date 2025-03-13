import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/services/share_plus.dart';

class SharePlusDelegate implements SharePlus {
  @override
  Future<ShareResult> shareXFiles(List<XFile> files) => Share.shareXFiles(files);
}
