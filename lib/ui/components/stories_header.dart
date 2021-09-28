import 'package:flutter/material.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class StoriesHeader extends StatefulWidget {
  final List<String> stories;

  const StoriesHeader(
      {this.stories = const [
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrpM3UTTyyqIwGsPYB1gCDhfl3XVv0Cex2Lw&usqp=CAU',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlCzsqcGBluOOUtgQahXtISLTM3Wb2tkpsoeMqwurI2LEP6pCS0ZgCFLQGiv8BtfJ9p2A&usqp=CAU',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEMWzdlSputkYso9dJb4VY5VEWQunXGBJMgGys7BLC4MzPQp6yfLURe-9nEdGrcK6Jasc&usqp=CAU',
        'https://mdbcdn.b-cdn.net/img/Photos/Avatars/img%20%2820%29.jpg',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHNX4Bb1o5JWY91Db6I4jf_wmw24ajOdaOPgRCqFlnEnxcAlQ42pyWJxM9klp3E8JoT0k&usqp=CAU',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF-rBV5pmJhYA8QbjpPcx6s9SywnXGbvsaxWyFi47oDf9JuL4GruKBY5zl2tM4tdgYdQ0&usqp=CAU',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF1L_s4YJh7RHSIag8CxT0LTuJQo-XQnTJkVApDXar4b0A57U_TnAMrK_l4Fd_Nzp65Bg&usqp=CAU'
      ]});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesHeader> {
  //TODO delete after building story model
  List<String> sampleNames = [
    'Evelyn',
    'Rita',
    'John',
    'Karen',
    'Sophia',
    'Romina',
    'Mark'
  ];
  List<double> sampleProgress = [
    0,
    0.5,
    0,
    0.35,
    0,
    0.7,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: widget.stories.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: StoriesItem(
                maxRadius: 30,
                name: sampleNames[index],
                imageUrl: widget.stories[index],
                progressValue: sampleProgress[index],
              ),
            );
          }),
    );
  }
}
