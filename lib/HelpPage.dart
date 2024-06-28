import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFA8DADC),
        title: Text(
          'Help & Contact',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blueGrey[900]),
              title: Text(
                'Email',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('support@PillPopIn.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blueGrey[900]),
              title: Text(
                'Phone',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('+1 234 567 890'),
            ),
            ListTile(
              leading: Icon(Icons.public, color: Colors.blueGrey[900]),
              title: Text(
                'Website',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('www.PillPopIn.com'),
            ),
            ListTile(
              leading: Icon(Icons.facebook, color: Colors.blueGrey[900]),
              title: Text(
                'Facebook',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('facebook.com/PillPopIn'),
            ),
            ListTile(
              leading: Icon(Icons.camera, color: Colors.blueGrey[900]),
              title: Text(
                'Instagram',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('instagram.com/PillPopIn'),
            ),
          ],
        ),
      ),
    );
  }
}
