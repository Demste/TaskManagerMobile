import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/pages/login_page.dart';
import 'package:todolist/models/active_user.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    String getRoleString(int role) {
      switch (role) {
        case 1:
          return 'Admin'; 
        case 2:
          return 'Kullanıcı'; 
        default:
          return 'Bilinmeyen Rol'; // Unknown Role
      }
    }

    // Retrieve user information from ActiveUser
    final userName = ActiveUser.instance.name;
    final userSurname = ActiveUser.instance.surname;
    final userRole = ActiveUser.instance.role;
    final userUrl = ActiveUser.instance.url;

    final userRoleString = getRoleString(userRole!);
    final TextEditingController nameController = TextEditingController(text: userName);
    final TextEditingController surnameController = TextEditingController(text: userSurname);
    final TextEditingController roleController = TextEditingController(text: userRoleString);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout_sharp),
            onPressed: () async{
              // Clear the ActiveUser from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('activeUser');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (Route<dynamic> route) => false, // Removes all previous routes
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Unfocus the text fields when tapping outside
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userUrl != null && Uri.tryParse(userUrl)?.isAbsolute == true
                      ? NetworkImage(userUrl)
                      : null, // Set to null to use the child widget
                  backgroundColor: Colors.grey[200],
                  child: userUrl == null || Uri.tryParse(userUrl)?.isAbsolute != true
                      ? const Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              // User Information
              _buildTextField(
                label: "İsim",
                controller: nameController,
                hintText: userName!,
              ),
              const SizedBox(height: 8.0),
              _buildTextField(
                label: "Soyisim",
                controller: surnameController,
                hintText: userSurname!,
              ),
              const SizedBox(height: 8.0),
              _buildTextField(
                label: "Rol",
                controller: roleController,
                hintText: userRoleString,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.transparent,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none, // Odaklanılmamış durumdaki sınır (none - yok)
              focusedBorder: OutlineInputBorder( // Odaklanılmış durumdaki sınır
                borderSide: const BorderSide(color: Colors.black, width: 2.0), // Sınırın rengi ve kalınlığı
                borderRadius: BorderRadius.circular(8.0), // Köşe yuvarlaklığı
              ),
            ),
          ),
        ],
      ),
    );
  }
}
