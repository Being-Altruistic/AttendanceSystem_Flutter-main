import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:http/http.dart' as http;
import 'package:attendancesystem/facultyDashboard.dart';

class OtpGenerator extends StatefulWidget {
  //Getting the NAME OF CLASSROOM from previous screen i.e. DASHBOARD, for which the OTP needs to be entered.
  final String value;

  const OtpGenerator({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<OtpGenerator> createState() => _OtpGeneratorState();
}

class _OtpGeneratorState extends State<OtpGenerator> {
  String textHolder = '';
  generateOtp() {
    setState(() {
      final code = OTP.generateTOTPCodeString(
          'JBSWY3DPEHPK3PXP', DateTime.now().millisecondsSinceEpoch,
          length: 4, interval: 10);

      textHolder = code;
    });
  }

  Future submitOtp() async {
    var url = "https://gopunchin.000webhostapp.com/otp.php";
    var response = await http.post(Uri.parse(url), body: {'otp': textHolder});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generate OTP for ${widget.value}"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your OTP will be generated below",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 25.0)),
            Text(
              textHolder,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20.0),
            ),
            ElevatedButton(
                style: ButtonStyle(
                    alignment: Alignment.center,
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black)),
                onPressed: () {
                  generateOtp();
                  submitOtp();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const LoginPage()),
                  // );
                },
                child: const Text('Generate OTP'))
          ],
        ),
      ),
    );
  }
}
