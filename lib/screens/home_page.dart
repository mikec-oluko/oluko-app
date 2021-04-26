import 'package:flutter/material.dart';
import 'package:oluko_app/elements/card-category.dart';
import 'package:oluko_app/elements/card-info.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        title: Text(widget.title),
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () {},
            child: Text('SIGN UP'),
            style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent, primary: Colors.transparent),
          )
        ],
      ),
      body: Column(children: [
        Container(
            height: 350,
            child: Stack(children: [
              Image(
                image: NetworkImage(
                    'https://blog.fitplanapp.com/wp-content/uploads/2019/05/best-gym-machines-for-legs-fitplan-1200x520.png'),
                fit: BoxFit.cover,
                height: 300,
                color: Colors.black,
                colorBlendMode: BlendMode.softLight,
              ),
              Positioned(
                  child: Padding(
                      padding: EdgeInsets.only(top: 30, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You are here',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                          Text(
                            'One Goal Achieved',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ))),
              Stack(alignment: Alignment.center, children: [
                Positioned(
                    bottom: 25,
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text('LEARN FROM THE BEST',
                              style: TextStyle(color: Colors.white))),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 50),
                            primary: Colors.brown.shade300),
                        child: Text('SIGN UP'),
                      )
                    ]))
              ])
            ])),
        CardInfo(
            img:
                'https://cdn.lifehack.org/wp-content/uploads/2014/07/deadlift-benefits.jpeg',
            title: 'WORKOUT WITH THE BEAST.',
            mainText: 'DWAYNE JHONSON',
            subtitle: 'Best Results Guaranteed')
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
