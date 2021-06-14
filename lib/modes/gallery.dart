import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../homepage.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final pdf = pw.Document();
  List<File>  _imagePick = [];
  List<Asset> _images = <Asset>[];
  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: false,
        selectedAssets: _images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          statusBarColor: "#d65338",
          actionBarColor: "#d65338",
          actionBarTitle: "Pick images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#d65338",
          startInAllView: true,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _images = resultList;
      AssetToImage();
    });
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      children: List.generate(_imagePick.length, (index) {
        return GestureDetector(
            onTap: () {
              getCroppedImaged(index);
            },
            child: Image.file(
              _imagePick[index],
              fit: BoxFit.cover,
            ));
      }),
    );
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _pdfName = TextEditingController();

  _ConvertPDF() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Convert to PDF",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: ScreenUtil().setSp(65),
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "PDF file name",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
                        ),
                      ),
                      TextFormField(
                        autofocus: true,
                        cursorColor: Color(0xffd65338),
                        controller: _pdfName,
                        validator: (value) {
                          return value.isNotEmpty ? null : "Can't be empty";
                        },
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffd65338),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffd65338),
                              ),
                            ),
                            labelText: "File name",
                            labelStyle: TextStyle(
                              color: Color(0xffd65338),
                              fontSize: ScreenUtil().setSp(50),
                            ),
                            errorStyle:
                                TextStyle(fontSize: ScreenUtil().setSp(30))),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(50),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(40),
                                    vertical: ScreenUtil().setHeight(20),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      ScreenUtil().setSp(60),
                                    ),
                                    border: Border.all(
                                      color: Color(0xffd65338),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Color(0xffd65338),
                                      fontSize: ScreenUtil().setSp(45),
                                    ),
                                  ))),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState.validate()) {
                                await createPDF();
                                await savePDF(_pdfName.text);
                                List<StorageInfo> storageInfo =
                                    await PathProviderEx.getStorageInfo();
                                var root = storageInfo[0].rootDir +
                                    "/Image to PDF Convertor";
                                Navigator.of(context).pop();

                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ViewPDF(
                                      title: "${_pdfName.text}.pdf",
                                      pathPDF: "$root/${_pdfName.text}.pdf",
                                    );
                                  },
                                ));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text(
                                  "PDF converted successfully",
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40),
                                  ),
                                )));
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(40),
                                vertical: ScreenUtil().setHeight(20),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  ScreenUtil().setSp(60),
                                ),
                                color: Color(0xffd65338),
                              ),
                              child: Text(
                                "Convert",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(45),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState

    loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Homepage()));
      },
      child: Container(
        color: Color(0xffd65338),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: ScreenUtil().setSp(90),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Homepage()));
                }),
            backgroundColor: Color(0xffd65338),
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "Gallery",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                ),
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: Container(
            margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                vertical: ScreenUtil().setHeight(20)),
            child: Column(
              children: [
                (_images.length == 0)
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "Please pick images",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(100),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Expanded(child: buildGridView()),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(ScreenUtil().setSp(30)),
                          primary: Color(0xffd65338),
                          shape: CircleBorder()),
                      onPressed: loadAssets,
                      child: Icon(
                        Icons.add,
                        size: ScreenUtil().setSp(80),
                      ),
                    ),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        if (_images.length != 0) {
                          _ConvertPDF();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                            "Please pick image",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          )));
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setSp(20)),
                        width: double.infinity,
                        height: ScreenUtil().setHeight(140),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setSp(60)),
                          color: Color(0xffd65338),
                        ),
                        child: Text(
                          "CONVERT TO PDF",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(70),
                          ),
                        ),
                      ),
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getCroppedImaged(index) async {
    String pathss =
        await FlutterAbsolutePath.getAbsolutePath(_images[index].identifier);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pathss,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 700,
        maxHeight: 700,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Color(0xffd65338),
            toolbarTitle: "Edit Image",
            showCropGrid: false,
            backgroundColor: Colors.white,
            statusBarColor: Color(0xffd65338),
            lockAspectRatio: false));
    if (croppedFile != null) {
      setState(() {
        _imagePick[index] = croppedFile;
      });
    }
  }

  // Future<File> compressFile(File file) async {
  //   final filePath = file.absolute.path;

  //   // Create output file path
  //   // eg:- "Volume/VM/abcd_out.jpeg"
  //   final lastIndex = filePath.lastIndexOf(new RegExp(r'.png'));
  //   final splitted = filePath.substring(0, (lastIndex));
  //   final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
  //   var result = await FlutterImageCompress.compressAndGetFile(

  //     file.absolute.path,
  //     outPath,
  //     quality: 55,
  //     format: CompressFormat.png,
  //   );

  //   print(file.lengthSync());
  //   print(result.lengthSync());

  //   return result;
  // }

  Future<File> compressFile(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 35,
    );
    return compressedFile;
  }

  AssetToImage() async {
    for (var item in _images) {
      String pathss =
          await FlutterAbsolutePath.getAbsolutePath(item.identifier);
      if (pathss != null) {
        var a = await compressFile(File(pathss));

        await _imagePick.add(a);
      }
      print("0000000000000===>>>$pathss");
      // _imagePick.add(File(pathss));
      setState(() {});
    }
  }

  createPDF() async {
    for (var img in _imagePick) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a3,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          }));
    }
  }

  savePDF(String name) async {
    try {
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      var root = storageInfo[0].rootDir + "/Image to PDF Convertor";
      final file = File("$root/$name.pdf");
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print(e.toString());
    }
  }
}
