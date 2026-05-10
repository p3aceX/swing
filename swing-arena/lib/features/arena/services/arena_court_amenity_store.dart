import '../models/arena_models.dart';

const arenaDefaultAmenities = [
  'Lights',
  'Parking',
  'Water',
  'Changing Rooms',
];

class ArenaCourtAmenityStore {
  ArenaCourtAmenityStore._();

  static final Map<String, List<String>> _savedAmenitiesByCourtId = {};

  static List<String> amenitiesForCourt(ArenaCourt court) {
    return List<String>.from(
        _savedAmenitiesByCourtId[court.id] ?? court.amenities);
  }

  static List<String> customAmenitiesForCourt(ArenaCourt court) {
    return amenitiesForCourt(court)
        .where((item) => !arenaDefaultAmenities.contains(item))
        .toList();
  }

  static void saveAmenities({
    required String courtId,
    required List<String> amenities,
  }) {
    _savedAmenitiesByCourtId[courtId] = List<String>.from(amenities);
  }
}
