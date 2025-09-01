import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsplit/app_strings.dart';
import 'package:whatsplit/trimmer_view.dart';

class TrimmerApp extends StatelessWidget {
  TrimmerApp({Key? key}) : super(key: key);

  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: GoogleFonts.mateSc(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff487267),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40, left: 40),
            child: Text(
              AppStrings.greetings,
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
                  AppStrings.loadVideo,
                  style: GoogleFonts.mateSc(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ButtonStyle(
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.white, width: 4),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xff487267),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                onPressed: () async {
                  final file =
                      await _picker.pickVideo(source: ImageSource.gallery);

                  if (file != null) {
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
            top: 350,
            left: 20,
            right: 20,
            child: Text(
              AppStrings.appDescription,
              style: TextStyle(
                fontSize: 50,
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
