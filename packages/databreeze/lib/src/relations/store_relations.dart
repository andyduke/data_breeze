import 'package:databreeze/src/relations/model_relation.dart';

class BreezeFetchRelationsRequest {
  final Set<BreezeModelRelation> relations;

  const BreezeFetchRelationsRequest({
    required this.relations,
  });
}
