import 'package:databreeze_flutter/src/base_controller.dart';
import 'package:databreeze_flutter/src/data_result.dart';
import 'package:databreeze_flutter/src/data_view_settings.dart';
import 'package:flutter/widgets.dart';

typedef BreezeDataViewBuilder<T> = Widget Function(BuildContext context, T data);
typedef BreezeDataViewErrorBuilder =
    Widget Function(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
      void Function() tryAgain,
    );

class BreezeDataView<T> extends StatefulWidget {
  final BreezeBaseDataController<T> controller;
  final bool autoFetch;
  final BreezeDataViewBuilder<T> builder;
  final WidgetBuilder? loadingBuilder;
  final BreezeDataViewErrorBuilder? errorBuilder;

  const BreezeDataView({
    super.key,
    required this.controller,
    this.autoFetch = true,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<BreezeDataView<T>> createState() => _BreezeDataViewState<T>();
}

class _BreezeDataViewState<T> extends State<BreezeDataView<T>> {
  late BreezeBaseDataController<T> _controller;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _attachController(widget.controller);
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
  void didUpdateWidget(covariant BreezeDataView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController(widget.controller);
    }
  }

  @override
  void dispose() {
    _detachController();

    super.dispose();
  }

  void _attachController(BreezeBaseDataController<T> newController) {
    _controller = newController;
    _controller.addListener(_updated);
  }

  void _detachController() {
    _controller.removeListener(_updated);
  }

  void _updated() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetch() async {
    await _controller.fetch();
  }

  void _reload() {
    _controller.fetch();
  }

  @override
  Widget build(BuildContext context) {
    final settings = BreezeDataViewSettings.of(context);
    final loadingBuilder = widget.loadingBuilder ?? settings.loadingBuilder;
    final errorBuilder = widget.errorBuilder ?? settings.errorBuilder;

    return switch (_controller.result) {
      BreezeResultSuccess<T>(data: var d) => widget.builder(context, d),
      BreezeResultError<T>(error: var e, stackTrace: var s) => errorBuilder(context, e, s, _reload),
      _ => loadingBuilder(context),
    };
  }
}
