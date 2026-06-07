class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.flunexia.fr/api/v1';
  static const String login = '/auth/login';
  static const String mobileDashboard = '/mobile/dashboard';
  static const String trips = '/trips';
  static const String requests = '/requests';
  static const String usersMe = '/users/me';

  static String requestsList({String? status}) {
    if (status == null || status.isEmpty) return requests;
    return '$requests?status=$status';
  }

  static String tripById(String tripId) => '/trips/$tripId';
  static String tripDuplicate(String tripId) => '/trips/$tripId/duplicate';

  static String requestsByTrip(String tripId) => '/requests?trip=$tripId';
  static String requestOffers(String requestId) =>
      '/requests/$requestId/offers';
  static String offerStatus(String offerId) => '/offers/$offerId/status';
}
