import 'dart:convert';

import 'package:flickr_img_search/bloc/search_bloc.dart';
import 'package:flickr_img_search/favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dependency_injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Поиск изображений',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var viewIcon = Icons.grid_view_rounded;
  int axisCount = 1;
  int page = 1;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final SharedPreferences prefs = di.sl();
    final images = context.select((SearchBloc bloc) => bloc.state.images);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.indigo.shade200,
      appBar: AppBar(
        title: SizedBox(
          height: 36,
          child: TextField(
              maxLines: 1,
              style: const TextStyle(fontSize: 17),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                filled: true,
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).iconTheme.color),
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search',
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
                context.read<SearchBloc>().add(SearchImgEvent(value, page));
              }),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Favorites(),
                  ),
                );
              },
              icon: const Icon(Icons.star)),
          IconButton(
            icon: Icon(viewIcon),
            onPressed: () {
              switch (axisCount) {
                case 1:
                  setState(() {
                    axisCount = 2;
                    viewIcon = Icons.view_comfy;
                  });
                  break; // The switch statement must be told to exit, or it will execute every case.
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
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              onPressed: () {
                page == 1 ? page = page : page -= 1;
                context.read<SearchBloc>().add(SearchImgEvent(query, page));
              },
              icon: const Icon(Icons.arrow_back)),
          IconButton(
              onPressed: () {
                setState(() {
                  page += 1;
                  context.read<SearchBloc>().add(SearchImgEvent(query, page));
                });
              },
              icon: const Icon(Icons.arrow_forward)),
        ],
      ),
      body: Center(
        child: images.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 95),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/images/flickr_logo.svg',
                      width: 220,
                    ),
                    SvgPicture.asset(
                      'assets/images/flickr.svg',
                    ),
                    const Text(
                      'Можно найти все',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
          onRefresh: refresh,
              child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: images.length,
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
                            favorites.add(images[index]);
                            prefs.setString('favorites', jsonEncode(favorites));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Изображение добавлено в избранное')));
                          },
                          child: Image.network(
                            "https://live.staticflickr.com/${images[index]['server']}/${images[index]['id']}_${images[index]['secret']}.jpg",
                            fit: BoxFit.none,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
      ),
    );
  }
  Future refresh() async {
    context.read<SearchBloc>().add(SearchImgEvent(query, page));
}
}