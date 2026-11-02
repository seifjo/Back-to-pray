import '../models/adhkar.dart';
import 'adhkar_library.dart';

/// Legacy morning/evening source kept for backward compatibility.
/// Prefer [AdhkarLibrary] for the live catalog.
class AdhkarData {
  static AdhkarCategory get morningAdhkar => AdhkarLibrary.morning;

  static AdhkarCategory get eveningAdhkar => AdhkarLibrary.evening;

  static List<AdhkarCategory> getAllAdhkar() => AdhkarLibrary.categories;
}
