import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:take_product/OurImageProvider.dart';
import  'package:save_in_gallery/save_in_gallery.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take Product',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Take Product'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  OurImageProvider ourImage;
  final picker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int init = 0;
  List<List<dynamic>> rowsAsListOfValues;
  List<dynamic> selectrdProduct;

  @override
  void initState(){
    super.initState();
  }

  Future getImage() async {
    selectrdProduct = rowsAsListOfValues[1];

    final pickedFile = await picker.getImage(source: ImageSource.camera, imageQuality: 50);
    
    setState(() {
      ourImage = OurImageProvider(imageProvider: FileImage(File(pickedFile.path)));
    });
  }

  Future getCsv() async {
    try{
final path = await FlutterDocumentPicker.openDocument();

                if(path != null) {
                  File _file = File(path);

                  String content = await _file.readAsString();
                  rowsAsListOfValues = const CsvToListConverter().convert(content);
                  init = rowsAsListOfValues.length - 1;
                  setState(() {
                    
                  });
                } else {
                  // User canceled the picker
                }
    }
    catch(e) { 
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Impossible de recuperer le contenu du csv.")));    
      }
    
  }

  Future saveImage() async {
    if(rowsAsListOfValues != null){
      if(rowsAsListOfValues.length == 2 && init > 0)
      {
        init = -1;
        rowsAsListOfValues = null;
        selectrdProduct = null;
        setState(() {});
        return;
      }
      
      final _imageSaver =  ImageSaver();
      selectrdProduct = rowsAsListOfValues[1];
      try{
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        var b = Uint8List.fromList(ourImage.bytes);
        bool c = await _imageSaver.saveImage(imageBytes: b, imageName:  selectrdProduct[0].toString() + ".png");
        if(c){
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Success"),backgroundColor: Colors.green,));  
        }
        else{
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Erreur,"),backgroundColor: Colors.red,));  
        }
      }
      catch (e)
      {

      }
      ourImage = null;
      rowsAsListOfValues.removeAt(1);
    }

    setState(() {
    });
  }

  Future passe() async {
    if(rowsAsListOfValues != null){
      if(rowsAsListOfValues.length == 2 && init > 0)
      {
        init = -1;
        rowsAsListOfValues = null;
        selectrdProduct = null;
        setState(() {
    });
        return;
      }
      rowsAsListOfValues.removeAt(1);

      ourImage = null;
    }

    setState(() {
    });
  }

  Widget displayProd()
  {
    selectrdProduct = rowsAsListOfValues != null ? rowsAsListOfValues[1] : ["",""];
    return Column(
      children: [
        Text((rowsAsListOfValues == null ? 0 : ((init - (rowsAsListOfValues.length-1)))).toString() + "/" + (init <= 0 ? 0 : (init-1)).toString(), style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
        Text(selectrdProduct[1], style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Take Product'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LinearProgressIndicator(value: (rowsAsListOfValues == null ? 0 : ((init - (rowsAsListOfValues.length-1)))/ (init-1))),
            displayProd(),
            init < 0 ? Text("Terminé.", style: TextStyle(fontSize: 56, color: Colors.green, fontWeight: FontWeight.bold),) :
            Center(
              child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ourImage == null
                  ? Text('No image selected.')
                  : Image(image: ourImage, height: 300,),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(child:FloatingActionButton(onPressed: saveImage, child: Icon(Icons.check,) ), visible: ourImage != null,),
                            Visibility(child:FloatingActionButton(onPressed: passe, child: Icon(Icons.next_plan, ),), visible: rowsAsListOfValues != null,),
                            Visibility(child:FloatingActionButton(onPressed: getImage,child: Icon(Icons.add_a_photo),), visible: rowsAsListOfValues != null,),
                          ]
                        ),
                      )
                    ],
                  ),
            ),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: getCsv,
            tooltip: 'Pick Image',
            child: Icon(Icons.file_upload),
          ),
    );
  }
}
