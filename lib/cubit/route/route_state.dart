part of 'route_cubit.dart';

@immutable
abstract class RouteState {}

class RouteInitial extends RouteState {}

class RoutePush extends RouteState {
  final int index;

  RoutePush(this.index);
}
