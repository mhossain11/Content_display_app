import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../screen/home_screen.dart';



class DeviceCheckWrapper extends StatefulWidget {
  const DeviceCheckWrapper({super.key});

  @override
  _DeviceCheckWrapperState createState() => _DeviceCheckWrapperState();
}

class _DeviceCheckWrapperState extends State<DeviceCheckWrapper> {
  bool? isSupported;

  @override
  void initState() {
    super.initState();
    checkDevice();
  }

  Future<void> checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final model = androidInfo.model.toLowerCase() ?? '';
    final device = androidInfo.device.toLowerCase() ?? '';
    final product = androidInfo.product.toLowerCase() ?? '';
    final manufacturer = androidInfo.manufacturer.toLowerCase() ?? '';

    print("📱 model: $model");
    print("📱 device: $device");
    print("📱 product: $product");
    print("📱 manufacturer: $manufacturer");
     var th = model.contains('redmi note 5');
    print("📱 bool: $th");

    // আপনার ফোনে যে model আসে, সেটার সাথে compare করুন
    if ( device.contains('whyred')||manufacturer.contains('sony') ||
        model.contains('zc-h982')||device.contains('zc-h982')||
        model.contains('rk3566_r')||device.contains('rk3566_r'))  {
      setState(() => isSupported = true);
      print('Match');
    } else {
      setState(() => isSupported = false);
      print('Not Match');
    }
    print("📱 bool1: $th");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (isSupported == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isSupported!) {
      // ❌ Not supported UI
      return Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: screenWidth /2,
                    //height: screenHeight / 2,


                    child: Image(image: AssetImage('assets/icon/warning.png'))),
              ),
              Center(
                child: Text(
                  "X App not supported any device.",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Your actual app
    return Scaffold(
      body: HomeScreen(),
    );
  }
}
