import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Place {
  final String name;
  final double lat;
  final double lng;

  Place({required this.name, required this.lat, required this.lng});

  factory Place.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return Place(
      name: json['name'],
      lat: location['lat'],
      lng: location['lng'],
    );
  }
}

class PlacesService {
  final String _key = 'AIzaSyA2spmVRxTetmqyb-HQOewSmUBgpFbBTMo';

  Future<List<Place>> getPlaces(double lat, double lng) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1500&type=parking&key=$_key',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final results = json['results'] as List<dynamic>;
      return results.map((place) => Place.fromJson(place)).toList();
    } else {
      throw Exception('Failed to load nearby parking places: ${response.body}');
    }
  }
}
