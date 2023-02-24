import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/components/introduction_page/introduction_slide.dart';
import 'package:reef_mobile_app/components/navigation/liquid_carousel_wrapper.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import 'package:reef_mobile_app/utils/styles.dart';

typedef ShouldRebuildFunction<T> = bool Function(T oldWidget, T newWidget);

class ShouldRebuild<T extends Widget> extends StatefulWidget {
  final T child;
  final ShouldRebuildFunction<T>? shouldRebuild;
  const ShouldRebuild({super.key, required this.child, this.shouldRebuild});
  @override
  // ignore: library_private_types_in_public_api
  _ShouldRebuildState createState() => _ShouldRebuildState<T>();
}

class _ShouldRebuildState<T extends Widget> extends State<ShouldRebuild> {
  @override
  ShouldRebuild<T> get widget => super.widget as ShouldRebuild<T>;
  T? oldWidget;
  @override
  Widget build(BuildContext context) {
    final T newWidget = widget.child;
    if (oldWidget == null ||
        (widget.shouldRebuild == null
            ? true
            : widget.shouldRebuild!(oldWidget!, newWidget))) {
      oldWidget = newWidget;
    }
    return oldWidget as T;
  }
}

class IntroductionPage extends StatelessWidget {
  final Future<void> Function() onDone;
  const IntroductionPage({Key? key, required this.title, required this.onDone})
      : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    //? Use a key to interact with the carousel from another widget (for triggering swipeToNext or swipeToPrevious from a button for example)
    final carouselKey = GlobalKey<LiquidCarouselState>();
    return Scaffold(
      body: LiquidCarousel(
        parentContext: context,
        key: carouselKey,
        children: <Widget>[
          const LiquidCarouselWrapper(),
          IntroductionSlide(
              key: const ValueKey(1),
              isFirst: true,
              liquidCarouselKey: carouselKey,
              color: Styles.splashBackgroundColor,
              buttonColor: Colors.deepPurpleAccent,
              title: "First View",
              child: Flex(
                crossAxisAlignment: CrossAxisAlignment.start,
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Image.asset(
                      "assets/images/intro.gif",
                      height: 240.0,
                      width: 240.0,
                    ),
                  ),
                  Flexible(
                      child: FittedBox(
                          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.reliable,
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.extensible,
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.efficient,
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.fast,
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            AppLocalizations.of(context)!.blockchain_for_defi,
                            style: TextStyle(fontSize: 16),
                          )),
                    ],
                  )))
                ],
              )),
          IntroductionSlide(
              key: const ValueKey(2),
              isLast: true,
              liquidCarouselKey: carouselKey,
              color: Colors.deepPurple.shade900,
              buttonColor: Colors.amberAccent,
              title: "Second View",
              done: onDone,
              child: Flex(
                crossAxisAlignment: CrossAxisAlignment.center,
                direction: Axis.vertical,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      "assets/images/reef.png",
                      height: 20.0,
                      width: 240.0,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Flex(
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .introducing_reef_chain,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 35),
                          Flexible(
                              child: Scrollbar(
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      child: SizedBox(
                                          child: (SingleChildScrollView(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .reef_chain_desc,
                                          style: TextStyle(
                                              fontSize: 16,
                                              height: 2,
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      )))))),
                        ],
                      ))
                ],
              )),
          const LiquidCarouselWrapper()
        ],
      ),
    );
  }
}
