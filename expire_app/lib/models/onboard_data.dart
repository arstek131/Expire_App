class OnBoarding {
  final String title;
  final String image;

  OnBoarding({
    required this.title,
    required this.image,
  });
}

List<OnBoarding> onboardingContents = [
  OnBoarding(
    title: 'Welcome to\n Expire app',
    image: 'assets/images/onboarding_1.png',
  ),
  OnBoarding(
    title: 'Create new family easily',
    image: 'assets/images/onboarding_2.png',
  ),
  OnBoarding(
    title: 'Keep track of your progress',
    image: 'assets/images/onboarding_3.png',
  ),
];