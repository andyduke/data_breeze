import 'package:databreeze_flutter/databreeze_flutter.dart';
import 'package:flutter/material.dart';

class FetchDemoScreen extends StatefulWidget {
  const FetchDemoScreen({
    super.key,
  });

  @override
  State<FetchDemoScreen> createState() => _FetchDemoScreenState();
}

class _FetchDemoScreenState extends State<FetchDemoScreen> {
  late final dataController = BreezeDataFetchController(
    onFetch: (isReload) => Future.delayed(
      const Duration(milliseconds: 500),
      () => [
        'Item 1',
        'Item 2',
        'Item 3',
        'Item 4',
      ],
    ),
    // refetchOnAutoUpdate: true,
  );

  @override
  void dispose() {
    dataController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Breeze FetchController Demo'),
      ),
      body: BreezeDataView(
        controller: dataController,
        builder: (context, data) => RefreshIndicator.adaptive(
          onRefresh: () => dataController.reload(),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(data[index]),
            ),
          ),
        ),
      ),
    );
  }
}
