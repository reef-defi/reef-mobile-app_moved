import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';

Future<dynamic> showModal(context,
    {child,
    dismissible = true,
    headText,
    Color background = Styles.primaryBackgroundColor,
    Color textColor = Styles.textColor}) {
  return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) => Center(
              child: SingleChildScrollView(
            child: CustomModal(
                child: child,
                headText: headText,
                dismissible: dismissible,
                background: background,
                textColor: textColor),
          )));
}

class CustomModal extends StatefulWidget {
  final Widget child;
  final String headText;
  final bool dismissible;
  final Color background;
  final Color textColor;

  const CustomModal({
    Key? key,
    required this.child,
    this.headText = "Transaction",
    this.dismissible = true,
    this.background = Styles.primaryBackgroundColor,
    this.textColor = Styles.textColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CustomModalState();
}

class CustomModalState extends State<CustomModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      // lowerBound: 0.5
    );
    scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCirc);

    _scaleController.addListener(() {
      setState(() {});
    });

    _scaleController.forward();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      // lowerBound: 0.5
    );
    fadeAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCirc);

    _fadeController.addListener(() {
      setState(() {});
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Dialog(
                  insetPadding: EdgeInsets.all(16),
                  backgroundColor: Colors.transparent,
                  child: ViewBoxContainer(
                    color: widget.background,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          buildHeader(context),
                          Container(child: widget.child),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Padding buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Image(
                image: AssetImage("./assets/images/reef.png"),
                width: 31,
                height: 31,
              )),
          Expanded(
              child: Text(
            widget.headText,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                color: widget.textColor,
                fontWeight: FontWeight.bold),
            overflow: TextOverflow.fade,
          )),
          if (widget.dismissible)
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      color: Colors.white,
                    ),
                    child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(CupertinoIcons.xmark,
                            color: Colors.black87, size: 12))

                    /*child: ElevatedButton(
                                    ,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(

                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size.fromRadius(4),
                                    backgroundColor: Styles.whiteColor,
                                    foregroundColor: Colors.grey[300],
                                    elevation: 2,
                                    shadowColor: Colors.black12),
                                child: const Icon(CupertinoIcons.xmark,
                                    color: Colors.black87, size: 12),
                              )*/
                    ))
        ],
      ),
    );
  }
}
