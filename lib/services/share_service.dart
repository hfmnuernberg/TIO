import 'package:share_plus/share_plus.dart';

mixin ShareService {
  Future<ShareResult> shareXFiles(List<XFile> files);
}

class ShareServiceImpl implements ShareService {
  @override
  Future<ShareResult> shareXFiles(List<XFile> files) => Share.shareXFiles(files);
}
