import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddPatientPage(),
    );
  }
}

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  // Define a common text style
  TextStyle commonTextStyle = TextStyle(
    color: Colors.blueGrey[900],
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  // Define a common border style
  OutlineInputBorder commonBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.black),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0), // Increased height
        child: AppBar(
          backgroundColor: Color.fromARGB(
              255, 181, 222, 247), // Bolder version of the background color
          flexibleSpace: Container(
            alignment: Alignment.bottomCenter, // Align row to the bottom
            padding: EdgeInsets.only(bottom: 10), // Add padding to bottom
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Image.asset(
                    'images/SmallLogo.png', // Make sure to add this image to your assets
                    height: 60.0, // Adjusted size
                    width: 60.0, // Adjusted size
                  ),
                  onPressed: () {
                    // Handle photo click
                  },
                ),
                IconButton(
                  icon: CustomPaint(
                    size: Size(60, 60), // Adjusted size of the custom icon
                    painter: PrescriptionIconPainter(),
                  ),
                  onPressed: () {
                    // Handle prescription icon click
                  },
                ),
                IconButton(
                  icon: Stack(
                    children: <Widget>[
                      Icon(Icons.person,
                          color: Colors.black, size: 60), // Adjusted size
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.add_circle,
                          color: Colors.blue,
                          size: 24, // Adjusted size
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    // Handle person icon with plus click
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Align items to the start (left side)
            children: [
              Text(
                'Add Patient',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Add some spacing
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Patient ID',
                  labelStyle: commonTextStyle,
                  border: commonBorder,
                  focusedBorder: commonBorder.copyWith(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: Icon(Icons.perm_identity, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Patient Email',
                  labelStyle: commonTextStyle,
                  border: commonBorder,
                  focusedBorder: commonBorder.copyWith(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Contact Number',
                  labelStyle: commonTextStyle,
                  border: commonBorder,
                  focusedBorder: commonBorder.copyWith(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: Icon(Icons.phone, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Handle add patient action
                  },
                  borderRadius: BorderRadius.circular(30.0),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 244, 167, 193), // Pastel Pink
                          Color(0xFFF06292), // Slightly darker Pastel Pink
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 4.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Center(
                      child: Text(
                        'Add Patient',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrescriptionIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final width = size.width;
    final height = size.height;

    // Draw the outer rectangle
    canvas.drawRect(
      Rect.fromLTWH(2, 2, width - 4, height - 4),
      paint,
    );

    // Draw the plus sign
    canvas.drawLine(
      Offset(width * 0.2, height * 0.2),
      Offset(width * 0.2, height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(width * 0.1, height * 0.3),
      Offset(width * 0.3, height * 0.3),
      paint,
    );

    // Draw the horizontal lines
    final lineLength = width * 0.6;
    final lineSpacing = height * 0.1;
    for (int i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(width * 0.35, lineSpacing * i),
        Offset(width * 0.35 + lineLength, lineSpacing * i),
        paint,
      );
    }

    // Draw the pills
    final pillWidth = width * 0.25;
    final pillHeight = height * 0.1;
    final pillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width * 0.35, height * 0.5, pillWidth, pillHeight),
        Radius.circular(5),
      ),
      pillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width * 0.55, height * 0.55, pillWidth, pillHeight),
        Radius.circular(5),
      ),
      pillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
