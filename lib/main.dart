
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override

  File? image ;
  final image_picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  String imageURL = '';
  final firestore = FirebaseFirestore.instance;


  Future getimage()async{
    final imagepath = await image_picker.pickImage(source: ImageSource.camera , imageQuality: 80);


    setState(() {
      if(imagepath!=null){
        print("IMAGE IS SELECTED have path ${imagepath.path}");
        image = File(imagepath.path);

      }
      else{
        print('No image select');
      }
    });

  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('UPLOAD IMAGE'),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: Center(
          child: Column(

            
            children: [
              SizedBox(height: 80,),
              Container(
                height: 230,
                width: 300,

                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),

                child: image !=null ? Image.file(image!,fit: BoxFit.cover,) : Icon(Icons.image_rounded,size: 100,),
              ),
              SizedBox(height: 80,),
              Row(children: [
                Expanded(child: SizedBox(width: 80,)),
                //BROWSE IMAGE
                Expanded(child: MaterialButton(

                  minWidth: 80.0,
                  color: Colors.greenAccent,
                  onPressed: () async{

                    final imagePicker  = await  image_picker.pickImage(source: ImageSource.camera) ;
                    setState(()  {

                      if(imagePicker!=null){

                        image = File(imagePicker.path);
                        print(imagePicker.path.toString());



                      }
                      else{
                        print('Image Not selected');
                      }

                    });
                  },

                child: Text("BROWSE",style: TextStyle(fontSize: 12.3),),
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.greenAccent , width: 2),
                  ),

                )),
                Expanded(child: SizedBox(width: 80,)),
                //UPLOAD IMAGE
                Expanded(child: MaterialButton(
                  minWidth: 80.0,
                  color: Colors.greenAccent,
                  onPressed: ()async {

                    Reference f1 = FirebaseStorage.instance.ref();
                    Reference f2 = f1.child('Images').child(DateTime.now().toString());

                    try{
                      await f2.putFile(image!);
                      imageURL = await f2.getDownloadURL();
                     print('DONEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
                     print(imageURL);
                      await firestore.collection('Link').doc('${DateTime.now()}').set(
                          {
                            'LINK' : imageURL,

                          });
                      print('DONE AGAINNNNNNNNNN');


                    }
                    catch(e){
                      print(e);
                    }

                  },
                  child: Text("UPLOAD",style: TextStyle(fontSize: 13),),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.greenAccent , width: 2),
                  ),

                )),
                Expanded(child: SizedBox(width: 80,)),

              ],),
              SizedBox(height: 30,),
              Container(
                height: 200,
                width: 290,
                color: Colors.transparent,
                child: StreamBuilder(
                stream: firestore.collection('Link').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot>snapshot) {
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return CircularProgressIndicator();
                    }
                    return (snapshot.hasData) ?
                      ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context , index) {
                      String link = snapshot.data!.docs[index]['LINK'];

                      return Container(
                        child: Image.network(link),
                      );
                    }
                    )


                        :Container();
                  }),
                ),






            ],
          ),
        ),
      ),
    );
  }
}
