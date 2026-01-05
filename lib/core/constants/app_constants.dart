/// Application-wide string constants.
/// Centralized location for all UI strings for easy maintenance and localization.
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // ==================== Authentication ====================

  // Login
  static const String loginTitle = 'Login';
  static const String loginButton = 'Login';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String dontHaveAccount = "Don't have an account? Sign up";
  static const String alreadyHaveAccount = 'Already have an account? Login';

  // Signup
  static const String signupTitle = 'Sign Up';
  static const String signupButton = 'Sign Up';

  // Validation
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // ==================== Dashboard ====================

  static const String postsTitle = 'Posts';
  static const String logout = 'Logout';
  static const String searchHint = 'Search posts...';
  static const String noPostsFound = 'No posts found';
  static const String welcomeMessage = 'Welcome! Loading posts...';
  static const String retry = 'Retry';
  static const String userPrefix = 'User';
  static const String pullToRefresh = 'Pull to refresh';
  static const String refreshing = 'Refreshing...';

  // ==================== Common ====================

  static const String loading = 'Loading...';
  static const String error = 'Error';

  // ==================== TextField Hints ====================

  static const String searchDefault = 'Search...';
}

/// Application-wide numeric constants.
class AppConstants {
  AppConstants._();

  // Validation
  static const int minimumPasswordLength = 6;

  // Pagination
  static const int postsPerPage = 20;
  static const double scrollThresholdForPagination = 0.9; // 90%

  // UI
  static const double defaultPadding = 16.0;
  static const double buttonVerticalPadding = 16.0;
  static const double borderRadius = 12.0;
  static const int maxPostBodyLines = 2;
}
