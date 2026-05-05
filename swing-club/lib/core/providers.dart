import 'package:flutter_host_core/flutter_host_core.dart';

import 'api_client.dart';

/// Wires swing-club's authenticated Dio into the shared flutter_host_core
/// repositories. Register in ProviderScope overrides at app startup.
final hostDioOverride = hostDioProvider.overrideWith(
  (ref) => ref.watch(apiClientProvider).dio,
);

/// Routes team/tournament/match calls through the admin API paths,
/// which allow the club app to create and manage teams on behalf of the academy.
final hostPathConfigOverride = hostPathConfigProvider.overrideWithValue(
  HostPathConfig.club(),
);
