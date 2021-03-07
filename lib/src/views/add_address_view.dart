import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/address_search.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/place_service.dart';
import 'package:uuid/uuid.dart';

class AddAddressView extends StatefulWidget {
  final List<MyLocation> address;

  AddAddressView({
    Key key,
    this.address,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final _controller = TextEditingController();
  final _nameController = TextEditingController();
  Suggestion suggestion;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionToken = Uuid().v4();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add an Address'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            readOnly: true,
            onTap: () async {
              final Suggestion result = await showSearch(
                context: context,
                delegate: AddressSearch(sessionToken),
              );
              if (result != null) {
                // final placeDetails = await PlaceApiProvider(sessionToken)
                //     .getPlaceDetailFromId(result.placeId);
                setState(() {
                  //add result.description or name to new list for listTile
                  _controller.text = result.description;
                  suggestion = result;
                  //print('placeDetails: $placeDetails');
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter your address',
              contentPadding: EdgeInsets.only(left: 8, top: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter a name for the location'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                final placeDetails = await PlaceApiProvider(sessionToken)
                    .getPlaceDetailFromId(suggestion.placeId);
                    if(_nameController.text == ''){
                      _nameController.text = 'Default';
                    }
                    //Add location to DB instead
                widget.address
                    .add(MyLocation(_nameController.text, placeDetails));
                  Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
