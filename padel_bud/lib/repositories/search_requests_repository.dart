import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_bud/models/search_request.dart';

class SearchRequestsRepository {
  final _db = FirebaseFirestore.instance.collection('search_requests');

  Future<DocumentReference> createSearchRequest(SearchRequestModel searchRequest) async {
    return await _db.add(searchRequest.toJson());
  }

  Future<void> deleteSearchRequest(String id) async {
    await _db.doc(id).delete();
  }
}
