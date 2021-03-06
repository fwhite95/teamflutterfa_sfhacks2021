import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/address_search.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/place_service.dart';
import 'package:uuid/uuid.dart';

class AddAddressView extends StatefulWidget {
  
  
  @override
  State<StatefulWidget> createState() => _AddAddressViewState();
  
}

class _AddAddressViewState extends State<AddAddressView> {

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
      ),
      body: Column(
      children: [
        TextField(
          controller: _controller,
          readOnly: true,
          onTap: () async {
        
            final sessionToken = Uuid().v4();
            final Suggestion result = await showSearch(
              context: context, 
              delegate: AddressSearch(sessionToken),
              );
              if(result != null){
                final placeDetails = await PlaceApiProvider(sessionToken)
                    .getPlaceDetailFromId(result.placeId);
                setState(() {
                  //add result.description or name to new list for listTile
                  _controller.text = result.description;
                  print('placeDetails: $placeDetails');
                  
                });
              }
          },
          decoration: InputDecoration(
            hintText: 'Enter your address',
            contentPadding: EdgeInsets.only(left: 8, top: 16),
          ),
        ),
      ],
    ),
    );
    
    
  }
  
}