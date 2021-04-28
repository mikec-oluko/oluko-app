import 'package:flutter/material.dart';

class SignUpWithMailPage extends StatefulWidget {
  SignUpWithMailPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailPageState createState() => _SignUpWithMailPageState();
}

class _SignUpWithMailPageState extends State<SignUpWithMailPage> {
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
        body: Container(
            color: Colors.brown.shade100,
            child: ListView(children: [
              Padding(
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
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Create an account, You are just one step away!',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w300),
                                  )
                                ])),
                        SizedBox(height: 75),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: 400,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(children: [
                                  TextField(
                                    decoration: new InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(
                                            color: Colors.grey[800]),
                                        hintText: "First Name",
                                        labelText: "First Name",
                                        fillColor: Colors.white70),
                                  ),
                                  TextField(
                                    decoration: new InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius:
                                              const BorderRadius.only(),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius:
                                              const BorderRadius.only(),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(
                                            color: Colors.grey[800]),
                                        hintText: "Last Name",
                                        labelText: "Last Name",
                                        fillColor: Colors.white70),
                                  ),
                                  TextField(
                                    decoration: new InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius:
                                              const BorderRadius.only(),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius:
                                              const BorderRadius.only(),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(
                                            color: Colors.grey[800]),
                                        hintText: "Your Email",
                                        labelText: "Email Address",
                                        fillColor: Colors.white70),
                                  ),
                                  TextField(
                                    decoration: new InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(
                                            color: Colors.grey[800]),
                                        hintText: "8 or more characters",
                                        labelText: "Password",
                                        fillColor: Colors.white70),
                                  ),
                                ]),
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
                                            child: Text('SIGN UP'),
                                          )
                                        ]))),
                                SizedBox(height: 10),
                                Text('Already a Subscribed user?'),
                                Text('Log In')
                              ],
                            ))
                      ])))
            ])));
  }
}
