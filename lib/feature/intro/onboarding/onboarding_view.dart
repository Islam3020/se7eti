import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:se7eti/core/functions/navigation.dart';
import 'package:se7eti/core/utils/colors.dart';
import 'package:se7eti/core/utils/text_style.dart';
import 'package:se7eti/core/widgets/custom_button.dart';
import 'package:se7eti/feature/intro/onboarding/onboarding_model.dart';
import 'package:se7eti/feature/intro/welcome_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  var pageController = PageController();
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          TextButton(
              onPressed: () {
               pushReplacement(context, const WelcomeView());
              },
              child: Text(
                'تخطي',
                style: getbodyStyle(color: AppColors.color1),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                  controller: pageController,
                  itemCount: 3,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const Spacer(),
                        SvgPicture.asset(
                          pages[index].image,
                          width: 250,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                        const Spacer(),
                        Text(
                          pages[index].title,
                          style: getTitleStyle(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          pages[index].body,
                          textAlign: TextAlign.center,
                          style: getbodyStyle(),
                        ),
                        const Spacer(flex: 2)
                      ],
                    );
                  }),
            ),
            SizedBox(
              height: 60,
              child: Row(children: [
                SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
                  effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 16,
                    activeDotColor: AppColors.color1,
                    dotColor: AppColors.greyColor,
                    spacing: 8,
                  ),
                ),
                const Spacer(),
                if (currentPage == 2) ...{
                  CustomButton(
                      height: 45,
                      width: 100,
                      text: 'هيا بنا',
                      onPressed: () {
                       pushReplacement(context,const WelcomeView());
                      }),
                }
              ]),
            )
          ],
        ),
      ),
    );
  }
}