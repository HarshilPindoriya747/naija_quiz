import 'dart:async';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 4010))
        ..addStatusListener(animationStatusListener);
  late AnimationController titleFadeAnimationController;

  late AnimationController clockAnimationController;
  late Animation<double> clockScaleUpAnimation;
  late Animation<double> clockScaleDownAnimation;

  late AnimationController logoAnimationController;
  late Animation<double> logoScaleUpAnimation;
  late Animation<double> logoScaleDownAnimation;

  void animationStatusListener(AnimationStatus animationStatus) {
    if (animationStatus == AnimationStatus.completed) {
      titleFadeAnimationController.forward(from: 0.0);
    }
  }

  late bool loadedSystemConfigDetails = false;

  @override
  void initState() {
    initAnimations();
    loadSystemConfig();

    super.initState();
  }

  void loadSystemConfig() async {
    await MobileAds.instance.initialize();
    await FacebookAudienceNetwork.init();
    print("Ads loaded successfully");

    context.read<SystemConfigCubit>().getSystemConfig();
  }

  void initAnimations() {
    clockAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    clockScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
            parent: clockAnimationController,
            curve: Interval(0.0, 0.4, curve: Curves.easeInOut)));
    clockScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.9).animate(
        CurvedAnimation(
            parent: clockAnimationController,
            curve: Interval(0.4, 1.0, curve: Curves.easeInOut)));

    logoAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    logoScaleUpAnimation = Tween<double>(begin: 0.0, end: 1.1).animate(
        CurvedAnimation(
            parent: logoAnimationController,
            curve: Interval(0.0, 0.4, curve: Curves.easeInOut)));
    logoScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
            parent: logoAnimationController,
            curve: Interval(0.4, 1.0, curve: Curves.easeInOut)));

    titleFadeAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    animationController.removeStatusListener(animationStatusListener);

    animationController.dispose();
    logoAnimationController.dispose();
    clockAnimationController.dispose();
    titleFadeAnimationController.dispose();
    super.dispose();
  }

  void navigateToNextScreen() async {
    // if (loadedSystemConfigDetails) {
    //Reading from settingsCubit means we are just reading current value of settingsCubit
    //if settingsCubit will change in future it will not rebuild it's child

    final currentSettings = context.read<SettingsCubit>().state.settingsModel;
    final currentAuthState = context.read<AuthCubit>().state;

    if (currentSettings!.showIntroSlider) {
      Navigator.of(context).pushReplacementNamed(Routes.introSlider);
    } else {
      if (currentAuthState is Authenticated) {
        context
            .read<UserDetailsCubit>()
            .fetchUserDetails(context.read<AuthCubit>().getUserFirebaseId());
        Navigator.of(context)
            .pushReplacementNamed(Routes.home, arguments: false);
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
      // }
    }
  }

  void startAnimation() async {
    await animationController.forward(from: 0.0);
    await clockAnimationController.forward(from: 0.0);
    await logoAnimationController.forward(from: 0.0);
    navigateToNextScreen();
  }

  Widget _buildSplashAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(UiUtils.getImagePath("LOGO.png"),
            height: MediaQuery.of(context).size.height * .35,
            width: MediaQuery.of(context).size.width * 4),
        // Image.asset(UiUtils.getImagePath("splasscreen logo.PNG"))
        // AnimatedBuilder(
        //   animation: clockAnimationController,
        //   builder: (context, child) {
        //     double scale = 0.8 +
        //         clockScaleUpAnimation.value -
        //         clockScaleDownAnimation.value;
        //     return Transform.scale(
        //       scale: scale,
        //       child: child,
        //     );
        //   },
        //   child: Lottie.asset("assets/animations/splashClock.json",
        //       controller: animationController, onLoaded: (composition) {
        //     animationController..duration = composition.duration;
        //     startAnimation();
        //   }),
        // ),
        // AnimatedBuilder(
        //     animation: logoAnimationController,
        //     builder: (context, child) {
        //       double scale = 0.0 +
        //           logoScaleUpAnimation.value -
        //           logoScaleDownAnimation.value;
        //       return Transform.scale(
        //         scale: scale,
        //         child: child,
        //       );
        //     },
        //     child: Center(
        //         child:
        //             Image.asset(UiUtils.getImagePath("splasscreen logo.PNG")))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          BlocConsumer<SystemConfigCubit, SystemConfigState>(
            bloc: context.read<SystemConfigCubit>(),
            listener: (context, state) {
              if (state is SystemConfigFetchSuccess) {
                Timer(Duration(seconds: 2), () {
                  navigateToNextScreen();
                });
                // }
              }
              if (state is SystemConfigFetchFailure) {
                print(state.errorCode);
                animationController.stop();
              }
            },
            builder: (context, state) {
              var center = Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                  top: 20,
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                child: Center(
                  key: Key("splashAnimation"),
                  child: _buildSplashAnimation(),
                ),
              );
              Widget child = center;
              if (state is SystemConfigFetchFailure) {
                child = Center(
                  key: Key("errorContainer"),
                  child: ErrorContainer(
                    showBackButton: true,
                    errorMessageColor: Theme.of(context).primaryColor,
                    errorMessage: AppLocalization.of(context)!
                        .getTranslatedValues(
                            convertErrorCodeToLanguageKey(state.errorCode)),
                    onTapRetry: () {
                      setState(() {
                        initAnimations();
                      });
                      context.read<SystemConfigCubit>().getSystemConfig();
                    },
                    showErrorImage: true,
                  ),
                );
              }

              return AnimatedSwitcher(
                  child: child,
                  duration: Duration(
                    microseconds: 500,
                  ));
            },
          ),
          // BlocBuilder<SystemConfigCubit, SystemConfigState>(
          //   bloc: context.read<SystemConfigCubit>(),
          //   builder: (context, state) {
          //     if (state is SystemConfigFetchFailure) {
          //       return Container();
          //     }
          //     return Align(
          //       alignment: Alignment.bottomCenter,
          //       child: Padding(
          //         padding: EdgeInsets.only(
          //           bottom: MediaQuery.of(context).size.height * (0.025),
          //         ),
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           mainAxisAlignment: MainAxisAlignment.end,
          //           children: [
          //             //need to show loader if system confing data loded after animation completed
          //             AnimatedBuilder(
          //                 animation: logoAnimationController,
          //                 builder: (context, child) {
          //                   if (logoAnimationController.value == 1.0 &&
          //                       !loadedSystemConfigDetails) {
          //                     return CircularProgressContainer(
          //                       heightAndWidth: 60,
          //                       useWhiteLoader: false,
          //                     );
          //                   }
          //                   return SizedBox(
          //                     height: 60.0,
          //                     width: 60.0,
          //                   );
          //                 }),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // )
        ],
      ),
    );
  }
}
