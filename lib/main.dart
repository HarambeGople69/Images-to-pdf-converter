import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'homepage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(MyApp());
}

// void main() => runApp(
//       DevicePreview(
//         enabled: !kReleaseMode,
//         builder: (context) => MyApp(), // Wrap your app
//       ),
//     );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(1080, 1920),
        builder: () {
          return MaterialApp(
            title: "Image to pdf converter",
            // locale: DevicePreview.locale(context), // Add the locale here
            // builder: DevicePreview.appBuilder,
            debugShowCheckedModeBanner: false,
            home: SplashScreens(),
          );
        });
  }
}

class SplashScreens extends StatefulWidget {
  @override
  _SplashScreensState createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), completed);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark
      )
    );

    return Container(
      color: Color(0xffd65338),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(
                flex: 2,
              ),
              Image.asset(
                "assets/icon1.png",
                height: ScreenUtil().setHeight(550),
                width: ScreenUtil().setHeight(550),
                fit: BoxFit.cover,
              ),
              Spacer(),
              SpinKitWave(
                size: ScreenUtil().setSp(175),
                color: Color(0xffd65338),
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void completed() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Homepage()));
  }
}
