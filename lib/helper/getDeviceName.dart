import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceName() async {
  String deviceName = '';

  try {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceName = iosInfo.name;
    } else if (Platform.isLinux) {
      final linuxInfo = await DeviceInfoPlugin().linuxInfo;
      deviceName = linuxInfo.name;
    } else {
      deviceName = 'Unknown Device'; // Handle other platforms or errors
    }
  } catch (error) {
    print('Error acquiring device information: $error');
  }

  return deviceName;
}
