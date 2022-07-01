import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';

class CoachRecommendedContentPreviewStack extends StatefulWidget {
  const CoachRecommendedContentPreviewStack({this.recommendationsList, this.titleForSection});
  final List<CoachRecommendationDefault> recommendationsList;
  final String titleForSection;

  @override
  _CoachRecommendedContentPreviewStackState createState() => _CoachRecommendedContentPreviewStackState();
}

class _CoachRecommendedContentPreviewStackState extends State<CoachRecommendedContentPreviewStack> {
  final String _useDefaultImage = 'defaultImage';
  final ImageProvider _defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  final double _maxWidth = 150;
  final double _maxHeight = 100;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            widget.titleForSection,
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
          ),
        ),
        Container(
            width: 150,
            height: 120,
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: videoContentPreviewStackCards(getThumbnails(recommendations: widget.recommendationsList)))
      ],
    );
  }

  Container videoContentPreviewStackCards(List<String> recommendationImages) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
              visible: recommendationImages != null && recommendationImages.length > 2,
              child: thirdElementPreview(recommendationImages.length > 2 ? recommendationImages[2] : recommendationImages[0])),
          Visibility(
              visible: recommendationImages != null && recommendationImages.length > 1,
              child: secondElementPreview(recommendationImages.length > 1 ? recommendationImages[1] : recommendationImages[0])),
          Visibility(
              visible: recommendationImages != null && recommendationImages.isNotEmpty,
              child: firstElementPreview(recommendationImages[0])),
        ],
      ),
    );
  }

  ImageProvider<Object> getImageToShowOnPreview(String imageUrl) {
    if (imageUrl != null && imageUrl != _useDefaultImage) {
      return NetworkImage(imageUrl);
    } else {
      return _defaultImage;
    }
  }

  Positioned thirdElementPreview(String imageUrl) {
    return Positioned(
      top: 20,
      child: Center(
        child: Container(
          decoration: videoCardDecoration(image: imageUrl),
          width: _maxWidth - 20,
          height: _maxHeight,
        ),
      ),
    );
  }

  Positioned secondElementPreview(String imageUrl) {
    return Positioned(
      top: 10,
      child: Center(
        child: Container(
          decoration: videoCardDecoration(image: imageUrl),
          width: _maxWidth - 10,
          height: _maxHeight,
        ),
      ),
    );
  }

  Positioned firstElementPreview(String imageUrl) {
    return Positioned(
      top: 0,
      child: Center(
        child: Container(
          decoration: videoCardDecoration(image: imageUrl),
          width: _maxWidth,
          height: _maxHeight,
        ),
      ),
    );
  }

  BoxDecoration videoCardDecoration({String image}) {
    return BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
        image: DecorationImage(image: getImageToShowOnPreview(image), fit: BoxFit.cover));
  }

  List<String> getThumbnails({List<CoachRecommendationDefault> recommendations}) {
    List<String> thumbnailsList = [];

    if (recommendations != null && recommendations.isNotEmpty) {
      List<CoachRecommendationDefault> limitRecommendations = [];
      recommendations.length >= 3
          ? limitRecommendations = recommendations.getRange(recommendations.length - 3, recommendations.length).toList()
          : limitRecommendations = recommendations;
      limitRecommendations.forEach((recommendation) {
        if (recommendation.contentImage != null) {
          thumbnailsList.add(recommendation.contentImage);
        } else {
          thumbnailsList.insert(0, _useDefaultImage);
        }
      });
    }

    return thumbnailsList;
  }
}
