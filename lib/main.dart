import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.43,
                color: Color(0XFFbb86fc),
              ),
            ),
            color: const Color(0XFF1f2020),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Center(
                    child: Text(
                      'Flutter Chrome Extension!',
                      style: TextStyle(
                        color: Color(0XFFe2e1e1),
                        fontSize: 18,
                        letterSpacing: 2,
                        wordSpacing: 3,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This a Google Chrome Extension developed with Flutter Web,\nby H. Yousefpour.',
                    style: TextStyle(
                      color: Color(0XFFa49fa1),
                      fontSize: 15,
                      wordSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
