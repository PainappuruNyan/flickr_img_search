part of 'search_bloc.dart';

abstract class SearchState {
  const SearchState();
}

class SearchImgState extends SearchState {
  final List<dynamic> images;
  final int page;

  SearchImgState({
    this.page = 1,
    required this.images,
  });
}

class LoadingState extends SearchState {}
