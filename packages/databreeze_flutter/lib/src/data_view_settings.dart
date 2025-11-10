import 'package:databreeze_flutter/src/data_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BreezeDataViewSettingsData {
  static const defaults = BreezeDataViewSettingsData(
    loadingBuilder: defaultLoadingBuilder,
    errorBuilder: defaultErrorBuilder,
  );

  final WidgetBuilder loadingBuilder;
  final BreezeDataViewErrorBuilder errorBuilder;

  const BreezeDataViewSettingsData({
    required this.loadingBuilder,
    required this.errorBuilder,
  });

  static Widget defaultLoadingBuilder(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 32,
        child: CircularProgressIndicator.adaptive(
          padding: EdgeInsets.all(8),
          strokeWidth: 3,
        ),
      ),
    );
  }

  static Widget defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
    void Function() tryAgain,
  ) {
    final theme = Theme.of(context);
    final padding = const EdgeInsets.all(12);

    Widget body = SelectionArea(
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: theme.colorScheme.error,
        ),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$error'),
            if (kDebugMode) Text('$stackTrace'),
          ],
        ),
      ),
    );

    if (Scrollable.maybeOf(context, axis: Axis.vertical) == null) {
      body = SingleChildScrollView(
        padding: padding,
        child: body,
      );
    } else {
      body = Padding(
        padding: padding,
        child: body,
      );
    }

    return Center(
      child: Card.outlined(
        child: body,
      ),
    );
  }
}

class BreezeDataViewSettings extends InheritedWidget {
  BreezeDataViewSettings({
    super.key,
    WidgetBuilder? loadingBuilder,
    BreezeDataViewErrorBuilder? errorBuilder,
    required super.child,
  }) : data = BreezeDataViewSettingsData(
         loadingBuilder: loadingBuilder ?? BreezeDataViewSettingsData.defaults.loadingBuilder,
         errorBuilder: errorBuilder ?? BreezeDataViewSettingsData.defaults.errorBuilder,
       );

  final BreezeDataViewSettingsData data;

  static BreezeDataViewSettingsData of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<BreezeDataViewSettings>()?.data ??
        BreezeDataViewSettingsData.defaults;
    return result;
  }

  @override
  bool updateShouldNotify(BreezeDataViewSettings oldWidget) => data != oldWidget.data;
}
