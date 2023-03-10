import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';

class UserCoverImageComponent extends StatefulWidget {
  final UserResponse currentAuthUser;
  final bool isHomeImage;
  final bool isLoadingState;

  const UserCoverImageComponent({this.currentAuthUser, this.isHomeImage = false, this.isLoadingState = false}) : super();

  @override
  State<UserCoverImageComponent> createState() => _UserCoverImageComponentState();
}

class _UserCoverImageComponentState extends State<UserCoverImageComponent> {
  Widget defaultWidgetNoContent = const SizedBox.shrink();
  @override
  Widget build(BuildContext context) {
    return profileCoverImage();
  }

  Widget profileCoverImage() {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            OlukoNeumorphismColors.appBackgroundColor,
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Stack(children: [
        if (widget.isLoadingState)
          Padding(
            padding: EdgeInsets.only(bottom: widget.isHomeImage ? MediaQuery.of(context).size.height / 4 : MediaQuery.of(context).size.height / 6),
            child: OlukoCircularProgressIndicator(),
          )
        else
          Container(
            width: MediaQuery.of(context).size.width,
            height: widget.isHomeImage ? MediaQuery.of(context).size.height / 2 : MediaQuery.of(context).size.height / 3,
            child: widget.currentAuthUser.coverImage == null
                ? defaultWidgetNoContent
                : Image(
                    image: CachedNetworkImageProvider(widget.currentAuthUser.coverImage),
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.colorBurn,
                    height: MediaQuery.of(context).size.height,
                  ),
          ),
        if (OlukoNeumorphism.isNeumorphismDesign && !widget.isHomeImage)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: MediaQuery.of(context).size.height / 10),
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
          const SizedBox.shrink(),
      ]),
    );
  }
}
