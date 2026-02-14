import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

extension ClassElementHelpers on ClassElement {
  List<String> get genericTypes {
    final result =
        typeParameters //
            .map((t) => t.displayName)
            .toList(growable: false);
    return result;
  }

  String? get modelKeyType {
    // print('[!] class $displayName');
    // for (final s in allSupertypes) {
    //   print('- ${s.element.displayName}');
    // }

    final model = allSupertypes.firstWhereOrNull((s) => s.element.displayName == 'BreezeModel');
    if (model == null) {
      throw Exception('Class "$displayName" must inherit BreezeModel.');
    }

    // for (final t in model.typeArguments) {
    //   print('* ${t.element?.displayName} - ${t.getDisplayString()}');
    // }

    final result = model.typeArguments.firstOrNull?.getDisplayString();
    return result;
  }
}

extension StringHelpers on String {
  String get quoted => '\'$this\'';
}
