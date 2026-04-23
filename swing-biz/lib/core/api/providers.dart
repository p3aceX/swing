import 'package:dio/dio.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

final dioProvider = Provider<Dio>((ref) => ApiClient.instance.dio);

/// Override the host_core dio provider so its repositories use our
/// authenticated Dio instance. Register this at the ProviderScope level.
final hostDioOverride = hostDioProvider.overrideWith(
  (ref) => ref.watch(dioProvider),
);
