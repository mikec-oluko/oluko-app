import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_user.dart';

class CoachCoverImage extends StatefulWidget {
  final CoachUser coachUser;

  const CoachCoverImage({Key key, this.coachUser}) : super(key: key);

  @override
  State<CoachCoverImage> createState() => _CoachCoverImageState();
}

class _CoachCoverImageState extends State<CoachCoverImage> {
  @override
  Widget build(BuildContext context) {
    return coachCover(context);
  }

  Widget coachCover(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Container(
          //VIDEO LIKE COVER IMAGE
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          child: Stack(
            children: [
              widget.coachUser.coverImage == null
                  ? Image(
                      image: AssetImage('assets/home/mvtthumbnail.png'),
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.colorBurn,
                      height: MediaQuery.of(context).size.height,
                    )
                  : Image(
                      image: CachedNetworkImageProvider(widget.coachUser.coverImage),
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.colorBurn,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
              if (OlukoNeumorphism.isNeumorphismDesign)
                Positioned(
                  top: 40,
                  left: 20,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
                            width: 52,
                            height: 52,
                            child: Image.asset(
                              'assets/courses/left_back_arrow.png',
                              scale: 3.5,
                            )),
                      )),
                )
              else
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
            ],
          )),
    );
  }
}
