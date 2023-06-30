part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {
  const SearchEvent();
}

class SearchImgEvent extends SearchEvent {
  const SearchImgEvent(this.query, this.page);

  final String query;
  final int page;
}
