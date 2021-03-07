import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:teamflutterfa_sfhacks2021/src/util/config.dart';

class MyLocation {
  String name = 'Default';
  Place place;

  MyLocation(String title, Place place){
    this.name = title;
    this.place = place;
  }
}

class Place {
  String lat;
  String lng;
  String name;

  Place({
    this.lat,
    this.lng,
  });
  

  @override
  String toString() {
    return 'Place(lat: $lat, lng: $lng)';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

//get more details about the place from the placeId.
//Use this to get lat lang?
  Future<Place> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry/location&key=$googleApiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        print('Result: $result');
        final place = Place();
        
        place.lat = result['result']['geometry']['location']['lat'].toString();
        place.lng = result['result']['geometry']['location']['lng'].toString();
        
        return place;
      }
      throw Exception(result['error_message']);
    }else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
