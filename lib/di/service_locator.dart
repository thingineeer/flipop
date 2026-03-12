import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;
  ServiceLocator._();

  late final AuthRepository authRepository;

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    authRepository = AuthRepositoryImpl();
    _initialized = true;
  }
}
