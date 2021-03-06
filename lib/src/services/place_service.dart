import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:teamflutterfa_sfhacks2021/src/util/config.dart';

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
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&components=country:ch&key=$googleApiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if(response.statusCode == 200) {
      final result = json.decode(response.body);
      print('result: $result');
      if(result['status'] == 'OK') {
        return result['predictions']
        .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
        .toList();
      }
      if(result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

//get more details about the place from the placeId.
//Use this to get lat lang? 
  // Future<Place> getPlaceDetailFromId(String placeId) async {

  // }
}