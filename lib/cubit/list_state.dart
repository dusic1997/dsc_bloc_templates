part of 'list_cubit.dart';

@immutable
class ListState<T> {
  final List<T> data;
  final dynamic error;

  const ListState({this.data = const [], this.error});
}

class ListInitial<T> extends ListState<T> {}

class ListError<T> extends ListState<T> {
  const ListError({super.error});
}

class ListNormal<T> extends ListState<T> {
  const ListNormal({super.data});
}
