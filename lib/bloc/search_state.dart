part of 'search_bloc.dart';

class SearchState {
  final List<dynamic> images;
  final int page;

  SearchState({
    this.page = 1,
    required this.images,
  });
}
