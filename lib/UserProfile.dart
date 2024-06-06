import 'package:flutter/material.dart';
import 'FavoritePage.dart'; // Import the FavoritePage
import 'EditProfilePage.dart'; // Import the EditProfilePage
import 'ResetPassword.dart'; // Import the ResetPassword

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Profile',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFFA8DADC), // Pastel Blue
          secondary: Color(0xFFFF9DC6), // Pastel Pink
          background: Color.fromARGB(255, 217, 242, 255), // White
          surface: Color.fromARGB(255, 175, 227, 252), // Pastel Bright Blue
          onPrimary: Color(0xFFFFFFFF), // White
          onSecondary: Color.fromARGB(255, 0, 0, 0), // Black
          onBackground: Color(0xFFB0BEC5), // Light Gray
          onSurface: Color(0xFFB0BEC5), // Light Gray
        ),
      ),
      home: UserProfile(),
    );
  }
}

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        backgroundColor: Color(0xFFA8DADC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              // backgroundImage: AssetImage('assets/images/your_photo.png'),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.black, // Change to black
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            ProfileMenuItem(
              icon: Icons.person,
              text: 'Profile',
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(),
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.favorite,
              text: 'Favorite',
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      userAnswers: {
                        'What time do you wake up in the morning?':
                            TimeOfDay(hour: 7, minute: 0),
                        'At what time do you have breakfast?':
                            TimeOfDay(hour: 8, minute: 0),
                        'What time do you have lunch?':
                            TimeOfDay(hour: 12, minute: 0),
                        'What time do you have dinner?':
                            TimeOfDay(hour: 18, minute: 0),
                        'What time do you go to bed at night?':
                            TimeOfDay(hour: 22, minute: 0),
                      },
                      questions: [
                        'What time do you wake up in the morning?',
                        'At what time do you have breakfast?',
                        'What time do you have lunch?',
                        'What time do you have dinner?',
                        'What time do you go to bed at night?',
                      ],
                      images: [
                        'images/sun.png', // Icon for waking up
                        'images/coffee.png', // Icon for breakfast
                        'images/launch.png', // Icon for lunch
                        'images/dinner.png', // Icon for dinner
                        'images/moon.png', // Icon for going to bed
                      ],
                    ),
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.lock,
              text: 'Password Manager',
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPassword(),
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.help,
              text: 'Help',
              press: () {},
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              text: 'Logout',
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback press;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            Icon(icon, color: Colors.black), // Change to black
            SizedBox(width: 20),
            Expanded(child: Text(text, style: TextStyle(color: Colors.black))),
            Icon(Icons.arrow_forward_ios,
                color: Colors.black), // Change to black
          ],
        ),
      ),
    );
  }
}
