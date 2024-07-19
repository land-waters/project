import 'package:get_it/get_it.dart';
import 'package:project/service/foodData_service.dart';

GetIt locator = GetIt.instance;

initLocator() {
  locator.registerLazySingleton<foodDataService>(() => FoodDataServiceImplementation());
}