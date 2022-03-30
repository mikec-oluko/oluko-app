import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum CollageTypeEnum { people, logos }

class CollageUtils {
  static List<Widget> getCollageWidgets(List<String> userSelfies, int qty) {
    List<Widget> collageWidgets = [];
    collageWidgets += addRealImages(userSelfies, qty);
    int remainingQty = remainingQuantity(collageWidgets.length, qty);
    collageWidgets += addFakeImages(CollageTypeEnum.people, remainingQty);
    remainingQty = remainingQuantity(collageWidgets.length, qty);
    collageWidgets += addFakeImages(CollageTypeEnum.logos, remainingQty);
    collageWidgets.shuffle();
    return collageWidgets;
  }

  static List<Widget> addRealImages(List<String> userSelfies, int qty) {
    List<Widget> realImages = [];
    if (userSelfies == null) return realImages;
    for (int i = userSelfies.length - 1; i >= 0; i--) {
      if (realImages.length < qty) {
        realImages.add(Image(
          image: CachedNetworkImageProvider(userSelfies[i]),
          fit: BoxFit.cover,
        ));
      } else {
        break;
      }
    }
    return realImages;
  }

  static List<Widget> addFakeImages(CollageTypeEnum type, int qty) {
    List<Widget> fakeImages = [];
    List<Widget> totalFakeImages = imagesToWidgets(type);
    if (qty == 0) {
      return fakeImages;
    } else if (qty < getCollageQuantity(type)) {
      return getXRandomWidgetsFromList(totalFakeImages, qty);
    } else {
      return totalFakeImages;
    }
  }

  static List<Widget> getXRandomWidgetsFromList(List<Widget> widgets, int qty) {
    widgets.shuffle();
    List<Widget> finalWidgets = [];
    for (int i = 0; i < qty; i++) {
      finalWidgets.add(widgets[i]);
    }
    return finalWidgets;
  }

  static List<Widget> imagesToWidgets(CollageTypeEnum type) {
    int qty = getCollageQuantity(type);
    List<Widget> imageWidgets = [];

    for (int i = 1; i < qty; i++) {
      imageWidgets.add(Image.asset(
        getRoute(type, i),
        fit: BoxFit.cover,
      ));
    }

    return imageWidgets;
  }

  static int getCollageQuantity(CollageTypeEnum type) {
    if (type == CollageTypeEnum.logos) {
      return 30;
    } else if (type == CollageTypeEnum.people) {
      return 40;
    } else {
      return 0;
    }
  }

  static String getRoute(CollageTypeEnum type, int element) {
    String route = 'assets/';
    if (type == CollageTypeEnum.logos) {
      route += 'collage_logos/';
    } else if (type == CollageTypeEnum.people) {
      route += 'collage_people/';
    }
    route += element.toString();
    if (type == CollageTypeEnum.logos) {
      route += '.png';
    } else if (type == CollageTypeEnum.people) {
      route += '.jpg';
    }

    return route;
  }

  static int remainingQuantity(int currentQty, int totalQty) {
    int subtraction = totalQty - currentQty;
    if (subtraction <= 0) {
      return 0;
    } else {
      return subtraction;
    }
  }
}
