import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FavoritePage.dart'; // Import the FavoritePage
import 'EditProfilePage.dart'; // Import the EditProfilePage
import 'ResetPassword.dart'; // Import the ResetPassword
import 'MyMedicines.dart'; // Import MyMedicines page
import 'LoginPage.dart'; // Import the LoginPage
import 'HelpPage.dart'; // Import the HelpPage
import 'HomePage.dart'; // Import HomePage
import 'TakeORMiss.dart'; // Import the new MedicineIntakePage

class UserProfile extends StatefulWidget {
  final String userId;

  UserProfile({required this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  int _selectedIndex = 1;
  String _userName = 'Loading...';
  String _gender = 'Unknown';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    try {
      // Find the document by the field 'ID'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        setState(() {
          _userName = userDoc['FullName'];
          _gender = userDoc['Gender'];
        });
      } else {
        setState(() {
          _userName = 'User not found';
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Error fetching user';
      });
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(userId: widget.userId)),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyMedicines(userId: widget.userId)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MedicineIntakePage(patientId: widget.userId)),
        );
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 217, 242, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Logout",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              child: Text(
                "No",
                style: TextStyle(color: Color(0xFF007BFF)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Yes",
                style: TextStyle(color: Color(0xFF007BFF)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
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
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  _gender == 'M' ? 'images/male.png' : 'images/female.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _userName,
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
                    builder: (context) =>
                        EditProfilePage(userId: widget.userId),
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
                      userId: widget.userId,
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
                    builder: (context) =>
                        ResetPassword(userId: widget.userId), // Add userId here
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.help,
              text: 'Help',
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpPage(), // Navigate to HelpPage
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              text: 'Logout',
              press: () {
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('images/SmallLogo.png', width: 40, height: 40),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30, color: Colors.black),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/Medicines.png', width: 40, height: 40),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 30, color: Colors.black),
            label: 'Statistics',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        showUnselectedLabels: true,
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
