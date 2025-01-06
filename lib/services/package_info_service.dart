import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';

class PackageInfoService with ListenableServiceMixin {
  ReactiveValue<PackageInfo>? _info;

  PackageInfoService() {
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    _info = ReactiveValue<PackageInfo>(await PackageInfo.fromPlatform());
    listenToReactiveValues([_info]);
  }

  PackageInfo? get info => _info == null ? null : _info!.value;
}
