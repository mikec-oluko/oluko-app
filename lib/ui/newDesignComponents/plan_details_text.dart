import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/routes.dart';

class PlanDetailsTextComponent extends StatefulWidget {
  const PlanDetailsTextComponent({
    @required this.currentIndex,
    @required this.plan,
  }) : super();
  final Plan plan;
  final int currentIndex;
  @override
  State<PlanDetailsTextComponent> createState() => _PlanDetailsTextComponentState();
}

class _PlanDetailsTextComponentState extends State<PlanDetailsTextComponent> {
  final DateTime _today = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return getTextDetailsForPlan(currentIndex: widget.currentIndex, currentIndexPlan: widget.plan);
  }

  Widget getTextDetailsForPlan({@required int currentIndex, @required Plan currentIndexPlan}) {
    List<Widget> _planDetailTextList = [
      _getCorePlanText(plan: currentIndexPlan),
      _getCoachPlansText(plan: currentIndexPlan),
    ];
    return currentIndex == 0 ? _planDetailTextList.first : _planDetailTextList.last;
  }

  Widget _getCorePlanText({Plan plan}) => Wrap(
        children: [_planDetailsTextWithCurrencyAndDate(plan), _planDetailsPromoAndManageText()],
      );

  Widget _getCoachPlansText({Plan plan}) => Wrap(
        children: [_planDetailsTextWithCurrencyAndDate(plan), _planDetailsPromoAndManageText(), _contactUsFullContent()],
      );

  Widget _planDetailsTextWithCurrencyAndDate(Plan plan) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
            'Your account will be charged ${_getCurrency(plan)} ${_getPrice(plan.applePrice.toString())} USD plus any tax on the ${_today.day} day of the month until you cancel or upgrade your membership.',
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.black)),
      );

  Widget _planDetailsPromoAndManageText() => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text('Promo code exceptions may apply. Manage your membership at any time from your account.',
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.black)),
      );

  Wrap _contactUsFullContent() => Wrap(
        children: [
          _planDetailsCoachAssignText(),
          _contactUsLink(),
        ],
      );

  Text _planDetailsCoachAssignText() => Text(
      'You will automatically enter a waitlist for 24 hours until your coach has been assigned. For any questions regarding your coaching subscription, please.',
      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.black));

  GestureDetector _contactUsLink() {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            routeLabels[RouteEnum.profileContactUs],
          );
        },
        child: Text('contact us',
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w800).copyWith(
              decoration: TextDecoration.underline,
            )));
  }

  String _getCurrency(Plan currentPlan) => currentPlan.currency == 'usd' ? '\$' : currentPlan.currency;

  String _getPrice(String price) => price.length > 2 ? '${price.substring(0, price.length - 2)}.${price.substring(price.length - 2, price.length)}' : price;
}
