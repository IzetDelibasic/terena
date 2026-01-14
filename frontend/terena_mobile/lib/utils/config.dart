class Config {
  static String get apiBaseUrl {
    return 'http://10.0.2.2:5001/api';
  }

  static String get stripePublishableKey {
    return 'pk_test_51SomYYGya2IzSCBhJoEWCUcq8IXENUCXMjoxAPzV9M8gENBTYH6PlBvwqqcq5Twvd1pOfelASzFiMEhxKA9NCkTh003nqmQTAp';
  }

  static const int requestTimeout = 30;
  static const int pageSize = 20;
}
