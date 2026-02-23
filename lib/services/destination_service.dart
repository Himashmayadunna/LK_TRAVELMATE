import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_model.dart';

class DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'destinations';

  /// Fetch all destinations
  Future<List<DestinationModel>> fetchDestinations() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => DestinationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Fetch destinations by category
  Future<List<DestinationModel>> fetchByCategory(String category) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs
        .map((doc) => DestinationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Fetch destinations by budget level
  Future<List<DestinationModel>> fetchByBudget(String budgetLevel) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('budgetLevel', isEqualTo: budgetLevel)
        .get();
    return snapshot.docs
        .map((doc) => DestinationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Search destinations by name
  Future<List<DestinationModel>> searchDestinations(String query) async {
    final snapshot = await _firestore.collection(_collection).get();
    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => DestinationModel.fromMap(doc.data(), doc.id))
        .where((dest) =>
            dest.name.toLowerCase().contains(lowerQuery) ||
            dest.description.toLowerCase().contains(lowerQuery) ||
            dest.category.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
