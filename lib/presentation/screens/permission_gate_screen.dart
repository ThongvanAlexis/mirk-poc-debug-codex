// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../infrastructure/permissions/location_permission_service.dart';

class PermissionGateScreen extends StatefulWidget {
  const PermissionGateScreen({required this.permissionService, required this.grantedBuilder, super.key});

  final LocationPermissionService permissionService;
  final WidgetBuilder grantedBuilder;

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen> with WidgetsBindingObserver {
  static final Logger _log = Logger('presentation.permission_gate');

  _PermissionGateView _view = _PermissionGateView.rationale;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPermission(logReason: 'initial_status'));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkPermission(logReason: 'resume'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_view) {
      _PermissionGateView.granted => widget.grantedBuilder(context),
      _PermissionGateView.denied => _PermissionStateScaffold(
        title: 'Location is disabled',
        body: 'Enable foreground location in system settings, then return to continue the Melun map test.',
        primaryLabel: 'Open Settings',
        primaryIcon: Icons.settings,
        onPrimaryPressed: _busy ? null : _openSettings,
        secondaryLabel: 'Check Permission',
        onSecondaryPressed: _busy ? null : () => _checkPermission(logReason: 'manual_check'),
      ),
      _PermissionGateView.rationale => _PermissionStateScaffold(
        title: 'Enable foreground location',
        body: 'The POC uses your current position to draw the blue dot, reveal 25 m fog discs, and write evidence logs for the renderer test.',
        primaryLabel: 'Enable Location',
        primaryIcon: Icons.location_on,
        onPrimaryPressed: _busy ? null : _requestPermission,
      ),
    };
  }

  Future<void> _requestPermission() async {
    setState(() {
      _busy = true;
    });
    try {
      final LocationPermissionState state = await widget.permissionService.requestWhenInUse();
      _applyPermissionState(state, reason: 'request');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _checkPermission({required String logReason}) async {
    final LocationPermissionState state = await widget.permissionService.status();
    if (!mounted) return;
    _applyPermissionState(state, reason: logReason, keepRationaleWhenDenied: logReason == 'initial_status');
  }

  Future<void> _openSettings() async {
    setState(() {
      _busy = true;
    });
    try {
      await widget.permissionService.openSettings();
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _applyPermissionState(LocationPermissionState state, {required String reason, bool keepRationaleWhenDenied = false}) {
    final _PermissionGateView nextView;
    if (state.canEnterMap) {
      nextView = _PermissionGateView.granted;
    } else if (keepRationaleWhenDenied) {
      nextView = _PermissionGateView.rationale;
    } else {
      nextView = _PermissionGateView.denied;
    }
    _log.info('permission_gate_state reason=$reason permission=${state.name} view=${nextView.name}');
    if (!mounted) return;
    setState(() {
      _view = nextView;
    });
  }
}

class _PermissionStateScaffold extends StatelessWidget {
  const _PermissionStateScaffold({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2536),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: const Color(0xFFF4F7FB), fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFC7D0DF), height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(onPressed: onPrimaryPressed, icon: Icon(primaryIcon), label: Text(primaryLabel)),
                  if (secondaryLabel != null) ...<Widget>[
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: onSecondaryPressed, child: Text(secondaryLabel!)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _PermissionGateView { rationale, denied, granted }
