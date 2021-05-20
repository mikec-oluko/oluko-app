import 'package:flutter/material.dart';
import 'package:oluko_app/elements/card-carousel.dart';
import 'package:oluko_app/elements/card-info.dart';
import 'package:oluko_app/elements/gallery-carousel.dart';
import 'package:oluko_app/models/SignUpResponse.dart';
import 'package:oluko_app/repositories/AuthRepository.dart';
import 'package:oluko_app/utils/AppMessages.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SignUpResponse profile;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return FutureBuilder(
        future: getProfile(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(widget.title),
              backgroundColor: Colors.white,
              actions: menuOptions(),
            ),
            body: ListView(children: [
              Column(children: [
                Container(
                    height: 550,
                    child: Stack(children: [
                      Image(
                        image: NetworkImage(
                            'https://www.bodybuilding.com/images/2016/june/5-leg-workouts-for-mass-tall-v2.jpg'),
                        fit: BoxFit.cover,
                        height: 500,
                        width: MediaQuery.of(context).size.width,
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 30),
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
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/sign-up'),
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
                    subtitle: 'Best Results Guaranteed'),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Column(children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'FAT LOSS',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ))),
                      GalleryCarousel(imgArray: [
                        {
                          'title': '6 WEEKS FAT LOSS',
                          'img':
                              'https://cdn.abmachinesguide.com/wp-content/uploads/2013/09/gym-abs-workouts-women.jpg'
                        },
                        {
                          'title': '6 WEEKS FAT LOSS',
                          'img':
                              'https://cdn.abmachinesguide.com/wp-content/uploads/2013/09/gym-abs-workouts-women.jpg'
                        }
                      ])
                    ])),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Column(children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'POWER LIFTING',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ))),
                      GalleryCarousel(imgArray: [
                        {
                          'title': 'TITLE PLACEHOLDER',
                          'img':
                              'https://medalladehierro.com/wp-content/uploads/2020/09/todo-lo-que-debes-saber-sobre-powerlifting.jpg'
                        },
                        {
                          'title': 'TITLE PLACEHOLDER',
                          'img':
                              'https://medalladehierro.com/wp-content/uploads/2020/09/todo-lo-que-debes-saber-sobre-powerlifting.jpg'
                        }
                      ])
                    ])),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Column(children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'GENERAL WELLBEING',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ))),
                      GalleryCarousel(imgArray: [
                        {
                          'title': 'TITLE PLACEHOLDER',
                          'img':
                              'https://www.helpguide.org/wp-content/uploads/young-woman-performing-pushups-indoors.jpg'
                        },
                        {
                          'title': 'TITLE PLACEHOLDER',
                          'img':
                              'https://www.helpguide.org/wp-content/uploads/young-woman-performing-pushups-indoors.jpg'
                        }
                      ])
                    ])),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Align(
                        child: Column(children: [
                      Text(
                        'VIEW ALL CATEGORIES',
                        style: TextStyle(fontSize: 20),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                        size: 24.0,
                        semanticLabel: 'All Categories',
                      )
                    ]))),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'CHOOSE YOUR PLAN',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ))),
                CardInfo(
                    img:
                        'https://d50b62f6164e0c4a0279-11570554cb5edae3285603e6ab25c978.ssl.cf5.rackcdn.com/html_body_blocks/images/000/015/052/original/LegExercises_en8c825a9da07728466075a593cb53aacc.jpg?1573170579',
                    title: 'UNLIMITED ACCESS TO VIDEOS',
                    mainText: '\$100',
                    subtitle: ''),
                CardInfo(
                    img:
                        'https://img.freepik.com/free-photo/calm-young-muscular-caucasian-woman-practicing-gym-with-weights-athletic-female-model-doing-strength-exercises-training-her-upper-lower-body-wellness-healthy-lifestyle-bodybuilding_155003-28048.jpg?size=626&ext=jpg&ga=GA1.2.1720694697.1619222400',
                    title: 'UNLIMITED ACCESS TO VIDEOS',
                    mainText: '\$200',
                    subtitle: ''),
                CardInfo(
                    img:
                        'https://metro.co.uk/wp-content/uploads/2021/04/GettyImages-1282109761-d2bc.jpg?quality=90&strip=all&zoom=1&resize=644%2C346',
                    title: 'UNLIMITED ACCESS TO VIDEOS',
                    mainText: '\$300',
                    subtitle: ''),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Text(
                          'TESTIMONIALS',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ))),
                CardCarousel(textArray: [
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
                ]),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Text(
                          'FAQ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ))),
                Container(
                    width: MediaQuery.of(context).size.width - 80,
                    child: Card(
                        elevation: 30,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 6.0, right: 6.0, bottom: 6.0),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
                                )
                              ],
                            ),
                          ),
                        ))),
                Container(
                    width: MediaQuery.of(context).size.width - 80,
                    child: Card(
                        elevation: 30,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 6.0, right: 6.0, bottom: 6.0),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
                                )
                              ],
                            ),
                          ),
                        ))),
                Container(
                    width: MediaQuery.of(context).size.width - 80,
                    child: Card(
                        elevation: 30,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 6.0, right: 6.0, bottom: 6.0),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
                                )
                              ],
                            ),
                          ),
                        ))),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text('READY TO GET STARTED?',
                              style: TextStyle(color: Colors.black))),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 50),
                            primary: Colors.brown.shade300),
                        child: Text('SIGN UP'),
                      )
                    ]))
              ])
            ]),
          );
        });
  }

  Future<void> getProfile() async {
    final profileData = await AuthRepository.retrieveLoginData();
    profile = profileData != null
        ? SignUpResponse.fromJson(profileData.toJson())
        : null;
  }

  List<Widget> menuOptions() {
    List<Widget> options = [];

    if (profile == null) {
      options.add(ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/sign-up')
            .then((value) => onGoBack()),
        child: Text('SIGN UP'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/log-in').then((value) => onGoBack()),
        child: Text('LOG IN'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
    } else {
      options.add(ElevatedButton(
        onPressed: () {
          AuthRepository.removeLoginData();
          AppMessages.showSnackbar(context, 'Logged out.');
          setState(() {});
        },
        child: Text('LOG OUT'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/profile')
            .then((value) => onGoBack()),
        child: Text('PROFILE'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
    }

    return options;
  }

  onGoBack() {
    setState(() {});
  }
}
