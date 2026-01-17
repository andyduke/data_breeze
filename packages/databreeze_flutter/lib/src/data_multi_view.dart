import 'package:databreeze_flutter/src/base_controller.dart';
import 'package:databreeze_flutter/src/data_result.dart';
import 'package:databreeze_flutter/src/data_view_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef BreezeDataMultiViewBuilder = Widget Function(BuildContext context);
typedef BreezeDataMultiViewErrorBuilder =
    Widget Function(
      BuildContext context,
      List<({Object error, StackTrace? stackTrace})> errors,
      void Function() tryAgain,
    );

class BreezeDataMultiView<T> extends StatefulWidget {
  final List<BreezeBaseDataController> controllers;
  final bool autoFetch;
  final BreezeDataMultiViewBuilder builder;
  final WidgetBuilder? loadingBuilder;
  final BreezeDataMultiViewErrorBuilder? errorBuilder;

  const BreezeDataMultiView({
    super.key,
    required this.controllers,
    this.autoFetch = true,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<BreezeDataMultiView<T>> createState() => _BreezeDataMultiViewState<T>();
}

class _BreezeDataMultiViewState<T> extends State<BreezeDataMultiView<T>> {
  final List<BreezeBaseDataController> _controllers = [];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _attachControllers(widget.controllers);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      if (widget.autoFetch) {
        _fetch();
      }
    }
  }

  @override
  void didUpdateWidget(covariant BreezeDataMultiView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.controllers, oldWidget.controllers)) {
      _detachControllers();
      _attachControllers(widget.controllers);
    }
  }

  @override
  void dispose() {
    _detachControllers();

    super.dispose();
  }

  void _attachControllers(List<BreezeBaseDataController> newControllers) {
    _controllers.clear();
    for (final newController in newControllers) {
      final controller = newController;
      controller.addListener(_updated);

      _controllers.add(controller);
    }
  }

  void _detachControllers() {
    for (final controller in _controllers) {
      controller.removeListener(_updated);
    }
    _controllers.clear();
  }

  void _updated() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetch() async {
    final futures = <Future>[];
    for (final controller in _controllers) {
      futures.add(controller.fetch());
    }
    await Future.wait(futures);
  }

  void _reload() {
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final settings = BreezeDataViewSettings.of(context);
    final loadingBuilder = widget.loadingBuilder ?? settings.loadingBuilder;

    final hasResult = _controllers.every((c) => c.result is BreezeResultSuccess || c.result is BreezeResultError);
    final errors = _controllers.where((c) => c.result is BreezeResultError).cast<BreezeResultError>();
    final hasErrors = errors.isNotEmpty;

    if (hasResult) {
      if (!hasErrors) {
        return widget.builder(context);
      } else {
        if (widget.errorBuilder != null) {
          return widget.errorBuilder!(
            context,
            errors.map((e) => (error: e.error, stackTrace: e.stackTrace)).toList(),
            _reload,
          );
        } else {
          return Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final error in errors) settings.errorBuilder(context, error.error, error.stackTrace, _reload),
            ],
          );
        }
      }
    } else {
      return loadingBuilder(context);
    }
  }
}
