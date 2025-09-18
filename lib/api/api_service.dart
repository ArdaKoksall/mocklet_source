import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:mocklet_source/app/data/app_constants.dart';
import 'package:mocklet_source/app_logger.dart';

import '../models/cached/crypto/crypto.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<List<Crypto>?> getData() async {
    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await _dio.get(AppConstants.getDataUrl);

        if (response.statusCode == 200) {
          return _listFromJson(response.data);
        } else {
          AppLogger.warning(
            'Failed to fetch data: ${response.statusCode}',
            'api_service',
          );
        }
      } catch (e) {
        AppLogger.info('Error fetching data (attempt ${attempt + 1}): $e');
      }

      attempt++;

      if (attempt < maxRetries) {
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    AppLogger.warning(
      'Failed to fetch data after $maxRetries attempts',
      'api_service',
    );
    return null;
  }

  List<Crypto> _listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Crypto.fromJson(json)).toList();
  }

  Future<bool> checkInternet() async {
    try {
      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 4));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
