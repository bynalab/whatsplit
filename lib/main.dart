import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsplit/splash_screen.dart';
import 'package:whatsplit/trimmer_view.dart';
import 'package:whatsplit/util/util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class TrimmerApp extends StatelessWidget {
  TrimmerApp({Key? key}) : super(key: key);

  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appTitle,
          style: GoogleFonts.mateSc(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        // alignment: AlignmentDirectional.centerEnd,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40, left: 40),
            child: Text(
              hi,
              style: TextStyle(
                fontSize: 150,
                fontFamily: 'Selima',
                fontWeight: FontWeight.bold,
                color: Color(0xff487267),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: 40,
            child: SizedBox(
              width: 200,
              height: 70,
              child: OutlinedButton(
                child: Text(
                  loadVideo,
                  style: GoogleFonts.mateSc(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    const BorderSide(color: Colors.white, width: 4),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    AppColors.primaryColor,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                onPressed: () async {
                  final result =
                      await _picker.pickVideo(source: ImageSource.gallery);
                  if (result != null) {
                    File file = File(result.path);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return TrimmerView(file);
                      }),
                    );
                  }
                },
              ),
            ),
          ),
          const Positioned(
            bottom: 100,
            left: 20,
            right: 10,
            child: Text(
              note,
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                fontFamily: 'Selima',
              ),
            ),
          )
        ],
      ),
    );
  }
}
