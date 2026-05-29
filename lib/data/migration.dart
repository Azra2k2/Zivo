import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_data.dart';

Future<void> migrateProductsToFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final products = AppData.products;

  final batch = firestore.batch();
  for (final product in products) {
    final ref = firestore.collection('products').doc(product.id);
    batch.set(ref, product.toMap());
  }
  await batch.commit();
  // ignore: avoid_print
  print('Migration complete');
}
