import 'package:dsc_bloc_templates/cubit/list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DscBlocSingleWidgetTemplate<T> extends StatelessWidget {
  const DscBlocSingleWidgetTemplate(
      {Key? key,
      required this.builder,
      required this.getData,
      this.errorWidgetBuilder})
      : super(key: key);
  final Widget Function(T) builder;
  final Future<T> Function() getData;
  final Widget Function(dynamic)? errorWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      var listCubit = ListCubit<T>(getPage: (
        _,
      ) async {
        return [await getData()];
      });
      listCubit.getData(isRefresh: true);
      return listCubit;
    }, child: BlocBuilder<ListCubit<T>, ListState<T>>(
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
        if (state.data.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return builder(state.data.first);
      },
    ));
  }
}
