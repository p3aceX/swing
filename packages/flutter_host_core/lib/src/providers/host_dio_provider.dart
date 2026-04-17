import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hostDioProvider = Provider<Dio>((ref) => Dio());
