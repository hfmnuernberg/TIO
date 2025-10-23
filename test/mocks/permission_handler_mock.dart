import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class PermissionHandlerMock with MockPlatformInterfaceMixin implements PermissionHandlerPlatform {
  PermissionStatus _status = PermissionStatus.denied;

  void grant() => _status = PermissionStatus.granted;
  void deny() => _status = PermissionStatus.denied;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async => _status;

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async => ServiceStatus.enabled;

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async => {
    for (final p in permissions) p: _status,
  };

  @override
  Future<bool> shouldShowRequestPermissionRationale(Permission permission) async => false;

  @override
  Future<bool> openAppSettings() async => true;
}
