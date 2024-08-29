import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/global.dart';
import 'package:todolist/home_page.dart';
import 'package:todolist/models/active_user.dart'; // ActiveUser sınıfını import edin

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
enum SupportState{
  unknown,
  supported,
  unSupported

}

class _LoginPageState extends State<LoginPage> {
  final Color textColor = Colors.orange;
  final LocalAuthentication auth=LocalAuthentication();
  SupportState supportState=SupportState.unknown;
  List<BiometricType>? availableBiometrics;

  bool _obscurePassword = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

   @override
   void initState(){
    auth.isDeviceSupported().
    then((bool isDeviceSupported)=>
    setState(
      ()=>supportState=isDeviceSupported?SupportState.supported:SupportState.unSupported,
    ));
    super.initState();
    checkBiometrics();
    getAvailableBiometrics();
    authWithBiometrics();
   }
  Future<void>checkBiometrics() async{
      // ignore: unused_local_variable
      late bool canCheckBiometrics;
      try{
        canCheckBiometrics=await auth.canCheckBiometrics;
        print("biometric supported");

      }on PlatformException catch(e){
        print("biometric not supported");
        print(e);
        canCheckBiometrics=false;

      }


    }
  Future<void>getAvailableBiometrics()async{
    late List<BiometricType> biometricTypes;
    try{
      biometricTypes=await auth.getAvailableBiometrics();

    }on PlatformException catch(e){
      print(e);
    }
    if(!mounted){
      return;

    }
    setState(() {
      availableBiometrics=biometricTypes;
    });
  }
  Future<void> authWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: "Auth with fingerprints or Face ID",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (!mounted) return;
      
      if (authenticated) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? activeUserJson = prefs.getString('activeUser');

        if (activeUserJson != null) {
          Map<String, dynamic> userMap = jsonDecode(activeUserJson);

          if (ActiveUser.isInitialized) {
            ActiveUser.instance.update(
              id: userMap['id'],
              role: userMap['role'],
              name: userMap['name'],
              surname: userMap['surname'],
              url: userMap['url'],
            );
          } else {
            ActiveUser.initialize(
              id: userMap['id'],
              role: userMap['role'],
              name: userMap['name'],
              surname: userMap['surname'],
              url: userMap['url'],
            );
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          _showErrorDialog('Kullanıcı bilgileri alınamadı. Şifreyle Giriş Yapın');
        }
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }



  Future<void> _signIn() async {
    final email = _usernameController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('E-Posta ve şifre boş olamaz.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final id = responseData['id'];
        final role = responseData['role'];
        final name = responseData['name'];
        final surname = responseData['surname'];
        final url = responseData['url'] ?? "null";

        if (ActiveUser.isInitialized) {
          ActiveUser.instance.update(
            id: id,
            role: role,
            name: name,
            surname: surname,
            url: url,
          );
        } else {
          ActiveUser.initialize(
            id: id,
            role: role,
            name: name,
            surname: surname,
            url: url,
          );
        }

        // Save ActiveUser to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('activeUser', jsonEncode({
          'id': id,
          'role': role,
          'name': name,
          'surname': surname,
          'url': url,
        }));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        _showErrorDialog('Kullanıcı verileri alınırken bir hata oluştu.');
      }
    } catch (e) {
      print(e);
      _showErrorDialog('Bir hata oluştu, lütfen tekrar deneyin.');
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(71, 57, 85, 0.8),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100,),
              Image.asset(
                'lib/images/performanz.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Başarı, tekrar tekrar denemekten gelir.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.white),
                  hintText: 'E-Posta ya da kullanıcı adı',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.white),
                  hintText: 'Şifre',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:()=> _showErrorDialog("Okan Beye Başvurun"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text(
                      'Şifremi Unuttum',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(57, 170, 94, 0.67),
                      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              IconButton(
                onPressed: authWithBiometrics, // The function to handle biometric authentication
                icon: const Icon(
                  Icons.fingerprint, // The fingerprint icon
                  color: Colors.white,
                ),
                iconSize: 40.0, // Adjust the size of the icon
                color: Colors.white,
                padding: const EdgeInsets.all(16.0), // Adjust padding to give it a button-like feel
                splashRadius: 30.0, // Customize the splash radius
                tooltip: 'Parmak İzi ile Giriş Yap', // Tooltip on long press
                style: IconButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(57, 170, 94, 0.67),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
