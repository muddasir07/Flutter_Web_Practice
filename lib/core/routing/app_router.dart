import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../layout/main_layout.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  GoRouter get router {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = authCubit.state.isAuthenticated;
        final currentPath = state.matchedLocation;
        final isAuthPage = currentPath == '/login' || currentPath == '/signup';

        if (!isAuthenticated && !isAuthPage) {
          return '/login';
        }

        if (isAuthenticated && isAuthPage) {
          return '/products';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductListPage(),
            ),
            GoRoute(
              path: '/products/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ProductDetailsPage(productId: id);
              },
            ),
          ],
        ),
      ],
    );
  }
}

