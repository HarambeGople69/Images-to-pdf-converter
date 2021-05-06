import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/modes/camera.dart';
import 'package:myapp/modes/gallery.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var files;

  void getFiles() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } //asyn function to get list of files
    try {
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      var root = storageInfo[0].rootDir +
          "/Image to PDF Convertor"; //storageInfo[1] for SD card, geting the root directory
      Directory(storageInfo[0].rootDir + "/Image to PDF Convertor")
          .create()
          .then((Directory directory) {
        print(directory.path);
      });
      var fm = FileManager(root: Directory(root)); //
      files = await fm.filesTree(
          // excludedPaths: ["/storage/emulated/0/Image to PDF Convertor"],
          extensions: ["pdf"] //optional, to filter files, list only pdf files
          );
      setState(() {}); //update the UI

    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    getFiles(); //call getFiles() function on initial state.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xffd65338), // navigation bar color
        statusBarColor: Color(0xffd65338),
        statusBarIconBrightness: Brightness.light // status bar color
        ));

    return WillPopScope(
      onWillPop: () {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Do you really want to quit?",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(70),
                  ),
                ),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(30),
                          vertical: ScreenUtil().setHeight(20),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setSp(50),
                          ),
                          border: Border.all(
                            color: Color(0xffd65338),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xffd65338),
                            fontSize: ScreenUtil().setSp(50),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        SystemNavigator.pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(30),
                          vertical: ScreenUtil().setHeight(20),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setSp(50),
                          ),
                          color: Color(0xffd65338),
                        ),
                        child: Text(
                          "Quit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(50),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              "All files",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(80),
              ),
            ),
          ),
          backgroundColor: Color(0xffd65338),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: files == null
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () {
                          getFiles();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xffd65338),
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(40),
                            vertical: ScreenUtil().setHeight(40),
                          ),
                        ),
                        child: Text(
                          "Get pdf from storage",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(70),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      //if file/folder list is grabbed, then show here
                      itemCount: files?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(40),
                              vertical: ScreenUtil().setHeight(20),
                            ),
                            child: ListTile(
                              title: Text(
                                files[index].path.split('/').last,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(50),
                                ),
                              ),
                              leading: Icon(
                                Icons.picture_as_pdf,
                                color: Color(0xffd65338),
                                size: ScreenUtil().setSp(70),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: Color(0xffd65338),
                                size: ScreenUtil().setSp(70),
                              ),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ViewPDF(
                                    pathPDF: files[index].path.toString(),
                                    title: files[index].path.split('/').last,
                                  );

                                  //open viewPDF page on click
                                }));
                              },
                            ));
                      },
                    ),
            ),
            GestureDetector(
              onTap: () {
                chooseMode(context);
              },
              child: Container(
                height: ScreenUtil().setHeight(175),
                width: double.infinity,
                color: Color(0xffd65338),
                child: Text(
                  "CONVERT TO PDF",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil().setSp(80),
                  ),
                ),
                alignment: Alignment.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  void chooseMode(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(50),
              vertical: ScreenUtil().setHeight(40),
            ),
            child: Container(
              height: ScreenUtil().setHeight(450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Choose photo:",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(90),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(
                    thickness: ScreenUtil().setHeight(7),
                    color: Color(0xffd65338),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(30),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return Gallery();
                      }));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Text(
                        "Gallery",
                        style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: ScreenUtil().setHeight(7),
                    color: Colors.grey[300],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(30),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();

                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return Camera();
                      }));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Text(
                        "Camera",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class ViewPDF extends StatelessWidget {
  String pathPDF = "";
  String title = "";
  ViewPDF({this.pathPDF, this.title});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        //view PDF
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(50),
              ),
            ),
          ),
          backgroundColor: Color(0xffd65338),
        ),
        path: pathPDF);
  }
}
