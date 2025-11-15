import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../features/product/models/product_model.dart';
import '../../features/product/data/datasources/product_local_datasource.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository.dart';
import '../../features/product/presentation/blocs/product_bloc.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/theme/presentation/cubits/theme_cubit.dart';
import '../constants/app_constants.dart';

class DependencyInjection {
  static Future<void> init() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register Hive adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserAdapter());
      }

      // Open Hive boxes
      await Hive.openBox<Product>(AppConstants.hiveBoxName);
      await Hive.openBox<int>('product_id_box');
      await Hive.openBox<User>('users_box');
      await Hive.openBox(AppConstants.authBoxName);
      await Hive.openBox(AppConstants.themeBoxName);
    } catch (e) {
      // If Hive fails, try to continue (for web compatibility)
      print('Hive initialization error: $e');
    }
  }

  static ProductBloc getProductBloc() {
    try {
      final localDataSource = ProductLocalDataSourceImpl(
        box: Hive.box<Product>(AppConstants.hiveBoxName),
        idBox: Hive.box<int>('product_id_box'),
      );
      final remoteDataSource = ProductRemoteDataSourceImpl(
        client: http.Client(),
      );
      final repository = ProductRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
      return ProductBloc(repository: repository);
    } catch (e) {
      // Fallback if Hive box is not available
      print('Error creating ProductBloc: $e');
      rethrow;
    }
  }

  static AuthCubit getAuthCubit() {
    try {
      final userBox = Hive.box<User>('users_box');
      final authBox = Hive.box(AppConstants.authBoxName);
      final repository = AuthRepositoryImpl(
        userBox: userBox,
        authBox: authBox,
      );
      return AuthCubit(repository);
    } catch (e) {
      print('Error creating AuthCubit: $e');
      rethrow;
    }
  }

  static ThemeCubit getThemeCubit() {
    try {
      return ThemeCubit(Hive.box(AppConstants.themeBoxName));
    } catch (e) {
      print('Error creating ThemeCubit: $e');
      // Return a default theme cubit
      return ThemeCubit(Hive.box(AppConstants.themeBoxName));
    }
  }
}

