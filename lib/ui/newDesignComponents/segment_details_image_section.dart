import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/constants/theme.dart';

class SegmentDetailsImageSection extends StatefulWidget {
  final String courseEnrollmentImageUrl;
  const SegmentDetailsImageSection({Key key, this.courseEnrollmentImageUrl}) : super(key: key);

  @override
  State<SegmentDetailsImageSection> createState() => _SegmentDetailsImageSectionState();
}

class _SegmentDetailsImageSectionState extends State<SegmentDetailsImageSection> {
  @override
  Widget build(BuildContext context) {
    return imageSection();
  }

  Widget imageSection() {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [OlukoNeumorphismColors.olukoNeumorphicBackgroundDark, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: imageContainer(),
    );
  }

  Stack imageContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        imageAspectRatio(),
      ],
    );
  }

  AspectRatio imageAspectRatio() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: () {
        if (widget.courseEnrollmentImageUrl != null) {
          return Image(
            image: CachedNetworkImageProvider(widget.courseEnrollmentImageUrl),
            fit: BoxFit.cover,
          );
        } else {
          return nil;
        }
      }(),
    );
  }
}
