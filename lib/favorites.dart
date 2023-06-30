import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dependency_injection.dart' as di;

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  var viewIcon = Icons.grid_view_rounded;
  int axisCount = 1;

  @override
  Widget build(BuildContext context) {
    var viewIcon = Icons.grid_view_rounded;
    final SharedPreferences prefs = di.sl();
    final localData = prefs.getString('favorites') ?? '';
    final favorites = localData.isNotEmpty ? jsonDecode(localData) : [];
    return Scaffold(
      backgroundColor: Colors.indigo.shade200,
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: <Widget>[
          IconButton(
            icon: Icon(viewIcon),
            onPressed: () {
              switch (axisCount) {
                case 1:
                  setState(() {
                    axisCount = 2;
                    viewIcon = Icons.view_comfy;
                  });
                  break;
                case 2:
                  setState(() {
                    axisCount = 4;
                    viewIcon = Icons.view_agenda_rounded;
                  });
                  break;
                case 4:
                  setState(() {
                    axisCount = 1;
                    viewIcon = Icons.grid_view_rounded;
                  });
                  break;
              }
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: favorites.isEmpty
          ? const Text('Your favorites is empty')
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              itemCount: favorites.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: axisCount),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FullScreenWidget(
                    disposeLevel: DisposeLevel.High,
                    child: GestureDetector(
                      onDoubleTap: () {
                        dynamic data = prefs.getString('favorites') ?? '';
                        List<dynamic> favorites = [];
                        if (data.isNotEmpty) {
                          favorites = [...jsonDecode(data)];
                        }
                        favorites.add(favorites[index]);
                        prefs.setString('favorites', jsonEncode(favorites));
                      },
                      child: Image.network(
                        "https://live.staticflickr.com/${favorites[index]['server']}/${favorites[index]['id']}_${favorites[index]['secret']}.jpg",
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                );
              }),
    );
  }
}
