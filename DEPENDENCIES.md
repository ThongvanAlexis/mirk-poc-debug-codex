# Dependency Audit

Audit date: 2026-05-02

Scope: every non-SDK package in `pubspec.lock`. Flutter SDK packages are excluded from the freshness gate because they are supplied by the pinned Flutter toolchain.

Policy: GPL, AGPL, LGPL, SSPL, unresolved licenses, MapLibre/Mapbox packages, telemetry SDKs, analytics SDKs, and ad SDKs fail `tool/check_licenses.dart`. Version drift fails `tool/check_dependencies_md.dart`.

## Direct Dependencies

| Package | Version | License | Source | Telemetry | Transitive licenses | Maintenance | Platform | Audit date |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| crypto | 3.0.7 | BSD-3-Clause | https://pub.dev hosted | Local app dependency; no analytics, ads, or automatic telemetry role. | Transitive packages are listed and audited below. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| cupertino_icons | 1.0.9 | MIT | https://pub.dev hosted | Local app dependency; no analytics, ads, or automatic telemetry role. | Transitive packages are listed and audited below. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| path | 1.9.1 | BSD-3-Clause | https://pub.dev hosted | Local app dependency; no analytics, ads, or automatic telemetry role. | Transitive packages are listed and audited below. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| path_provider | 2.1.5 | BSD-3-Clause | https://pub.dev hosted | Platform API plumbing only; no analytics, ads, or automatic telemetry role. | Transitive packages are listed and audited below. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |

## Dev Dependencies

| Package | Version | License | Source | Telemetry | Transitive licenses | Maintenance | Platform | Audit date |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| flutter_lints | 6.0.0 | BSD-3-Clause | https://pub.dev hosted | Development/test tooling only; no runtime telemetry role. | Package row audited directly. | Pinned dev/tooling package in pubspec.lock. | Local development and CI. | 2026-05-02 |
| test | 1.30.0 | BSD-3-Clause | https://pub.dev hosted | Development/test tooling only; no runtime telemetry role. | Package row audited directly. | Pinned dev/tooling package in pubspec.lock. | Local development and CI. | 2026-05-02 |
| yaml | 3.1.3 | MIT | https://pub.dev hosted | Development/test tooling only; no runtime telemetry role. | Package row audited directly. | Pinned dev/tooling package in pubspec.lock. | Local development and CI. | 2026-05-02 |

## Transitive Dependencies

| Package | Version | License | Source | Telemetry | Transitive licenses | Maintenance | Platform | Audit date |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| _fe_analyzer_shared | 93.0.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| analyzer | 10.0.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| args | 2.7.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| async | 2.13.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| boolean_selector | 2.1.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| characters | 1.4.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| cli_config | 0.2.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| clock | 1.1.2 | Apache-2.0 | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| code_assets | 1.0.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| collection | 1.19.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| convert | 3.1.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| coverage | 1.15.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| fake_async | 1.3.3 | Apache-2.0 | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| ffi | 2.2.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| file | 7.0.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| frontend_server_client | 4.0.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| glob | 2.1.3 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| hooks | 1.0.3 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| http_multi_server | 3.2.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| http_parser | 4.1.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| io | 1.0.5 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| jni | 1.0.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| jni_flutter | 1.0.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| leak_tracker | 11.0.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| leak_tracker_flutter_testing | 3.0.10 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| leak_tracker_testing | 3.0.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| lints | 6.1.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| logging | 1.3.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| matcher | 0.12.19 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| material_color_utilities | 0.13.0 | Apache-2.0 | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| meta | 1.17.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| mime | 2.0.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| native_toolchain_c | 0.17.6 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| node_preamble | 2.0.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| objective_c | 9.3.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| package_config | 2.2.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| path_provider_android | 2.3.1 | BSD-3-Clause | https://pub.dev hosted | Platform API plumbing only; no analytics, ads, or automatic telemetry role. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| path_provider_foundation | 2.6.0 | BSD-3-Clause | https://pub.dev hosted | Platform API plumbing only; no analytics, ads, or automatic telemetry role. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| path_provider_linux | 2.2.1 | BSD-3-Clause | https://pub.dev hosted | Platform API plumbing only; no analytics, ads, or automatic telemetry role. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| path_provider_platform_interface | 2.1.2 | BSD-3-Clause | https://pub.dev hosted | Platform API plumbing only; no analytics, ads, or automatic telemetry role. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| path_provider_windows | 2.3.0 | BSD-3-Clause | https://pub.dev hosted | Platform API plumbing only; no analytics, ads, or automatic telemetry role. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |
| platform | 3.1.6 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| plugin_platform_interface | 2.1.8 | BSD-3-Clause | https://pub.dev hosted | Platform API plumbing only; no analytics, ads, or automatic telemetry role. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| pool | 1.5.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| pub_semver | 2.2.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| record_use | 0.6.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| shelf | 1.4.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| shelf_packages_handler | 3.0.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| shelf_static | 1.1.3 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| shelf_web_socket | 3.0.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| source_map_stack_trace | 2.1.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| source_maps | 0.10.13 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| source_span | 1.10.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| stack_trace | 1.12.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| stream_channel | 2.1.4 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| string_scanner | 1.4.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| term_glyph | 1.2.2 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| test_api | 0.7.10 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| test_core | 0.6.16 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| typed_data | 1.4.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| vector_math | 2.2.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| vm_service | 15.2.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| watcher | 1.2.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| web | 1.1.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| web_socket | 1.0.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| web_socket_channel | 3.0.3 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| webkit_inspection_protocol | 1.2.1 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Dart/Flutter package. | 2026-05-02 |
| xdg_directories | 1.1.0 | BSD-3-Clause | https://pub.dev hosted | No analytics, ads, telemetry, MapLibre, or Mapbox package-name match. | Package row audited directly. | Pinned package in pubspec.lock. | Platform bridge/support package. | 2026-05-02 |

