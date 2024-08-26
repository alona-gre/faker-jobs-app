import 'package:faker_app_flutter_firebase/src/data/functions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class DeleteAllUserJobsController extends StateNotifier<AsyncValue<void>> {
  final FunctionsRepository functionsRepository;

  DeleteAllUserJobsController({required this.functionsRepository})
      : super(const AsyncData<void>(null));

  Future<void> deleteAllUserJobs() async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => functionsRepository.deleteAllUserJobs(),
    );
  }
}

final deleteAllUserJobsControllerProvider =
    StateNotifierProvider<DeleteAllUserJobsController, AsyncValue<void>>((ref) {
  return DeleteAllUserJobsController(
      functionsRepository: ref.watch(functionsRepositoryProvider));
});
