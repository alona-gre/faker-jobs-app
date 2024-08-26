import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:faker/faker.dart' hide Job;
import 'package:faker_app_flutter_firebase/src/common_widgets/alert_dialog.dart';
import 'package:faker_app_flutter_firebase/src/controllers/delete_all_user_jobs_controller.dart';
import 'package:faker_app_flutter_firebase/src/data/firestore_repository.dart';
import 'package:faker_app_flutter_firebase/src/data/job.dart';
import 'package:faker_app_flutter_firebase/src/routing/app_router.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deleteAllUserJobsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs'), actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: state.isLoading
              ? null
              : () async {
                  try {
                    await ref
                        .read(deleteAllUserJobsControllerProvider.notifier)
                        .deleteAllUserJobs();
                  } catch (e) {
                    if (e is FirebaseFunctionsException) {
                      showAlertDialog(
                        context: context,
                        title: 'An error occurred',
                        content: e.message,
                      );
                    }
                  }
                },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => context.goNamed(AppRoute.profile.name),
        )
      ]),
      body: const JobsListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isLoading
            ? null
            : () {
                final user = ref.read(firebaseAuthProvider).currentUser;
                final faker = Faker();
                final title = faker.job.title();
                final company = faker.company.name();
                ref.read(firestoreRepositoryProvider).addJob(
                      user!.uid,
                      title,
                      company,
                    );
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class JobsListView extends ConsumerWidget {
  const JobsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreRepository = ref.watch(firestoreRepositoryProvider);
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final state = ref.watch(deleteAllUserJobsControllerProvider);
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return FirestoreListView<Job>(
        query: firestoreRepository.jobsQuery(user!.uid),
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(error.toString()),
          );
        },
        loadingBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        emptyBuilder: (context) => const Center(child: Text('No data')),
        itemBuilder: (BuildContext context, QueryDocumentSnapshot<Job> doc) {
          final job = doc.data();
          return Dismissible(
            key: Key(doc.id),
            background: Container(
              color: Colors.red,
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              final user = ref.read(firebaseAuthProvider).currentUser;
              ref
                  .read(firestoreRepositoryProvider)
                  .deleteJob(user!.uid, doc.id);
            },
            child: ListTile(
                title: Text(job.title),
                subtitle: Text(job.company),
                trailing: job.createdAt != null
                    ? Text(
                        job.createdAt.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : null,
                onTap: () {
                  final user = ref.read(firebaseAuthProvider).currentUser;
                  final faker = Faker();
                  final title = faker.job.title();
                  final company = faker.company.name();
                  ref.read(firestoreRepositoryProvider).updateJob(
                        user!.uid,
                        doc.id,
                        title,
                        company,
                      );
                }),
          );
        });
    // FirestoreQueryBuilder<Job>(
    //   query: firestoreRepository.jobsQuery(user!.uid),
    //   builder: (context, snapshot, _) {
    //     if (snapshot.isFetching) {
    //       return const Center(child: CircularProgressIndicator());
    //     }

    //     if (snapshot.hasError) {
    //       return Center(
    //         child: Text('Something went wrong! ${snapshot.error}'),
    //       );
    //     }
    //     if (!snapshot.hasData) {
    //       return const Center(child: Text('No data'));
    //     }

    //     final jobs = snapshot.docs;

    //     return ListView.builder(
    //       itemCount: jobs.length,
    //       itemBuilder: (context, index) {
    //         final job = jobs[index].data();

    //         // if we reached the end of the currently obtained items, we try to
    //         // obtain more items
    //         if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
    //           // Tell FirestoreQueryBuilder to try to obtain more items.
    //           // It is safe to call this function from within the build method.
    //           snapshot.fetchMore();
    //         }
    //         return Dismissible(
    //           key: Key(jobs[index].id),
    //           background: Container(
    //             color: Colors.red,
    //           ),
    //           direction: DismissDirection.endToStart,
    //           onDismissed: (direction) {
    //             final user = ref.read(firebaseAuthProvider).currentUser;
    //             ref
    //                 .read(firestoreRepositoryProvider)
    //                 .deleteJob(user!.uid, jobs[index].id);
    //           },
    //           child: ListTile(
    //               title: Text(job.title),
    //               subtitle: Text(job.company),
    //               trailing: job.createdAt != null
    //                   ? Text(
    //                       job.createdAt.toString(),
    //                       style: Theme.of(context).textTheme.bodySmall,
    //                     )
    //                   : null,
    //               onTap: () {
    //                 final user = ref.read(firebaseAuthProvider).currentUser;
    //                 final faker = Faker();
    //                 final title = faker.job.title();
    //                 final company = faker.company.name();
    //                 ref.read(firestoreRepositoryProvider).updateJob(
    //                       user!.uid,
    //                       jobs[index].id,
    //                       title,
    //                       company,
    //                     );
    //               }),
    //         );
    //       },
    //     );
    //   },
    // );
  }
}
