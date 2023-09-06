import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'list_state.dart';

class ListCubit<T> extends Cubit<ListState<T>> {
  ListCubit({required this.getPage, this.params = const []})
      : super(ListInitial<T>());
  final Future<List<T>?> Function(int) getPage;
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);
  int page = 1;
  bool isEnd = false;
  final List params;
  void reset() {
    emit(ListInitial());
  }

  Future<void> getData({bool isRefresh = false}) async {
    var data = List<T>.from(state.data);

    if (isRefresh) {
      isEnd = false;
      page = 1;
      data = [];
    }
    if (isEnd) {
      return;
    }
    List<T>? res;

    try {
      res = await getPage(page);
    } catch (e) {
      emit(ListError<T>(error: e));
      return;
    }
    if (res == null || res.isEmpty) {
      isEnd = true;
      return;
    }

    data.addAll(res);
    page++;
    emit(ListNormal<T>(data: data));
  }
}
