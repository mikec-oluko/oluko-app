import 'package:flutter/material.dart';

class TransformationJourneyContentDetail extends StatefulWidget {
  const TransformationJourneyContentDetail();

  @override
  _TransformationJourneyContentDetailState createState() =>
      _TransformationJourneyContentDetailState();
}

class _TransformationJourneyContentDetailState
    extends State<TransformationJourneyContentDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [],
        ),
      ),
    );
  }
}
