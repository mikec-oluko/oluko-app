import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';

class CoachProfile extends StatefulWidget {
  final UserResponse coachUser;
  const CoachProfile({this.coachUser});

  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  String _userLocation;

  @override
  void initState() {
    _userLocation = getUserLocation(widget.coachUser);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        color: OlukoColors.black,
        constraints: BoxConstraints.expand(),
        child: ListView(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  coachCover(context),
                  coachInformationComponent(context),
                  uploadCoverButton(context),
                  coachGallery(context),
                  askCoachComponent(context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container coachCover(BuildContext context) {
    return Container(
      //VIDEO LIKE COVER IMAGE
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      child: widget.coachUser.coverImage == null
          ? SizedBox()
          : Image.network(
              widget.coachUser.coverImage,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.colorBurn,
              height: MediaQuery.of(context).size.height,
            ),
    );
  }

  askCoachComponent(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          //VIDEO LIKE COVER IMAGE
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            // color: Colors.blue,
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/assessment/play.png',
                                  scale: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Image.asset(
                                    'assets/courses/audio.png',
                                    width: 100,
                                    fit: BoxFit.fill,
                                    scale: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ask your coach",
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.white,
                                custoFontWeight: FontWeight.w500),
                          ),
                          Container(
                            clipBehavior: Clip.none,
                            width: 40,
                            height: 40,
                            child: TextButton(
                                onPressed: () {},
                                child: Icon(
                                  Icons.mic_rounded,
                                  color: OlukoColors.primary,
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  coachGallery(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Text(
                  "View All",
                  style: OlukoFonts.olukoMediumFont(
                      customColor: OlukoColors.primary,
                      custoFontWeight: FontWeight.w500),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                children: [
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: OlukoColors.blackColorSemiTransparent,
                      )),
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: OlukoColors.blackColorSemiTransparent,
                      )),
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: OlukoColors.blackColorSemiTransparent,
                      )),
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: OlukoColors.blackColorSemiTransparent,
                      )),
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: OlukoColors.blackColorSemiTransparent,
                      )),
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: OlukoColors.blackColorSemiTransparent,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned uploadCoverButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 5,
      right: 10,
      child: Visibility(
        visible: true,
        child: Container(
          clipBehavior: Clip.none,
          width: 40,
          height: 40,
          child: TextButton(
              onPressed: () {},
              child: Image.asset('assets/profile/uploadImage.png')),
        ),
      ),
    );
  }

  Positioned coachInformationComponent(BuildContext context) {
    return Positioned(
      //COACH INFORMATION
      top: MediaQuery.of(context).size.height / 4,
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: ContainerGradient.getContainerGradientDecoration(),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: widget.coachUser.coverImage == null
                              ? CircleAvatar(
                                  backgroundColor: OlukoColors.black,
                                  radius: 30.0,
                                )
                              : CircleAvatar(
                                  backgroundColor: OlukoColors.black,
                                  backgroundImage: Image.network(
                                    widget.coachUser.avatarThumbnail,
                                    fit: BoxFit.contain,
                                    frameBuilder: (BuildContext context,
                                            Widget child,
                                            int frame,
                                            bool wasSynchronouslyLoaded) =>
                                        ImageUtils.frameBuilder(context, child,
                                            frame, wasSynchronouslyLoaded,
                                            height: 30, width: 30),
                                    height: 30,
                                    width: 30,
                                  ).image,
                                  radius: 30.0,
                                ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.coachUser.firstName,
                                style: OlukoFonts.olukoBigFont(
                                    customColor: OlukoColors.primary,
                                    custoFontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                widget.coachUser.lastName,
                                style: OlukoFonts.olukoBigFont(
                                    customColor: OlukoColors.primary,
                                    custoFontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            _userLocation,
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.grayColor,
                                custoFontWeight: FontWeight.w300),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  String getUserLocation(UserResponse user) {
    String userLocationContent;
    if (user.city != null && (user.state != null && user.country != null)) {
      userLocationContent = "${user.city}, ${user.state} ${user.country}";
    }
    return userLocationContent;
  }
}