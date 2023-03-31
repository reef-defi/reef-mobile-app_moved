import 'package:flutter/material.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';

class SliderStandAlone extends StatefulWidget {
  final double rating;
  final Function(double) onChanged;

  const SliderStandAlone({Key? key, required this.rating, required this.onChanged})
      : super(key: key);

  @override
  _SliderStandAloneState createState() => _SliderStandAloneState();
}

class _SliderStandAloneState extends State<SliderStandAlone> {
  double rating = 0.0;
  late TextEditingController amountController;
  late TextEditingController amountTopController;

  @override
  void initState() {
    rating = widget.rating;
    amountController = TextEditingController();
    amountTopController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        showValueIndicator: ShowValueIndicator.never,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: Color(0xff742cb2),
        thumbColor: const Color(0xff742cb2),
        inactiveTickMarkColor: Color(0xffc0b8dc),
        trackShape: const GradientRectSliderTrackShape(
            gradient: LinearGradient(colors: <Color>[
              Color(0xffae27a5),
              Color(0xff742cb2),
            ]),
            darkenInactive: true),
        activeTickMarkColor: const Color(0xffffffff),
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
        thumbShape: const ThumbShape(),
      ),
      child: Slider(
        value: rating,
        onChanged:(newRating){
          setState(() {
            rating = newRating;
          });
          widget.onChanged(rating);
          },
        divisions: 100,
        label: "${(rating * 100).toInt()}%",
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    amountTopController.dispose();
    super.dispose();
  }
}
