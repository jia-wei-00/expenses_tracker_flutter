import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'route_state.dart';

class RouteCubit extends Cubit<RouteState> {
  RouteCubit() : super(RouteInitial());

  void pushRoute(int index) {
    emit(RoutePush(index));
  }
}
