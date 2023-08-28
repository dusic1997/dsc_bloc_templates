import 'package:dsc_bloc_templates/cubit/list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DscBlocTemplate<T> extends StatelessWidget {
  const DscBlocTemplate(
      {Key? key,
      required this.getPage,
      required this.itemBuilder,
      this.errorWidgetBuilder,
      this.enablePullDown = true,
      this.enablePullUp = true,
      this.bottomWidget})
      : super(key: key);
  final Future<List<T>?> Function(int) getPage;
  final Widget Function(T, int) itemBuilder;
  final Widget Function(dynamic)? errorWidgetBuilder;
  final bool enablePullDown;
  final bool enablePullUp;
  final Widget? bottomWidget;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListCubit<T>(getPage: getPage),
      child: Builder(builder: (context) {
        return BlocBuilder<ListCubit<T>, ListState<T>>(
          builder: (context, state) {
            var cubit = context.read<ListCubit<T>>();
            if (state is ListError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    errorWidgetBuilder?.call(state.error) ?? const Text('出错了'),
                    IconButton(
                        onPressed: () async {
                          cubit.reset();
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
              );
            }

            return SmartRefresher(
              controller: cubit.refreshController,
              enablePullUp: enablePullUp,
              enablePullDown: enablePullDown,
              onLoading: () async {
                try {
                  await cubit.getData(isRefresh: false);
                } catch (e) {
                  // TODO
                }
                cubit.refreshController.loadComplete();
              },
              onRefresh: () async {
                try {
                  await cubit.getData(isRefresh: true);
                } catch (e) {
                  // TODO
                }
                cubit.refreshController.refreshCompleted();
              },
              child: ListView.builder(
                itemCount: state.data.length + (bottomWidget != null ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (bottomWidget != null && index == state.data.length) {
                    return bottomWidget!;
                  }
                  return itemBuilder(state.data[index], index);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
