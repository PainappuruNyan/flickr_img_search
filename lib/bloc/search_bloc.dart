import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'api_key.dart';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'search_event.dart';

part 'search_state.dart';

const apiUrl = 'https://www.flickr.com/services/rest';

EventTransformer<E> debounceDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.debounce(duration), mapper);
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState(images: [])) {
    on<SearchImgEvent>(
      _onSearch,
      transformer: debounceDroppable(
        const Duration(seconds: 3),
      ),
    );
  }
  final _httpClient = Dio();

  _onSearch(SearchImgEvent event, Emitter<SearchState> emit) async {
    if (event.query.length < 3) return;
    final res = await _httpClient.get(
      apiUrl,
      queryParameters: {
        'method': 'flickr.photos.search',
        'api_key': apiKey,
        'text': event.query,
        'page': event.page,
        'format': 'json',
        'nojsoncallback': 1,
      },
    );
    emit(SearchState(images: res.data['photos']['photo'], page: res.data['photos']['page']));
  }
}
