import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Sign Up'),
          backgroundColor: Colors.white,
          actions: [],
        ),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  SizedBox(height: 20),
                  Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.cancel),
                        color: Colors.grey,
                        iconSize: 30,
                        onPressed: () => Navigator.pop(context),
                      )),
                  SizedBox(height: 20),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign Up to get started',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Create an account, You are just one step away!',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            )
                          ])),
                  SizedBox(height: 75),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                  onPressed: () {},
                                  child: Stack(children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Image.network(
                                        'https://img.icons8.com/color/452/google-logo.png',
                                        width: 30,
                                      ),
                                    ),
                                    Align(
                                      child: Text('Sign In with Google'),
                                    )
                                  ]))),
                          SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                  onPressed: () {},
                                  child: Stack(children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Image.network(
                                        'https://cdn.icon-icons.com/icons2/1826/PNG/512/4202110facebooklogosocialsocialmedia-115707_115594.png',
                                        width: 30,
                                      ),
                                    ),
                                    Align(
                                      child: Text('Sign In with Facebook'),
                                    )
                                  ]))),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text('- Or you can also -')),
                          SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.brown.shade300),
                                  onPressed: () {},
                                  child: Stack(children: [
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(Icons.navigate_next)),
                                    Align(
                                      child: Text('SIGN UP WITH EMAIL'),
                                    )
                                  ]))),
                          SizedBox(height: 10),
                          Text('By Sharing your email you agree to our'),
                          Text('Terms of Service and Privacy Policy')
                        ],
                      ))
                ]))));
  }
}
