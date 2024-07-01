import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facelogin/home/models/task.dart';

class FirestoreRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GetStorage _getStorage = GetStorage();

  static Future<void> create({required Task task}) async {
    try {
      String email = _getStorage.read('email') ?? '';
      await _firestore.collection(email).doc(task.id).set(task.toMap());
    } catch (e) {
      throw Exception('Gagal menambahkan tugas: $e');
    }
  }

  static Future<List<Task>> get() async {
    List<Task> taskList = [];
    try {
      String email = _getStorage.read('email') ?? '';
      final data = await _firestore.collection(email).get();
      for (var task in data.docs) {
        taskList.add(Task.fromMap(task.data() as Map<String, dynamic>));
      }
      return taskList;
    } catch (e) {
      throw Exception('Gagal mendapatkan daftar tugas: $e');
    }
  }

  static Future<List<Task>> getTodayTasks(String date) async {
    List<Task> taskList = [];
    try {
      String email = _getStorage.read('email') ?? '';
      final data = await _firestore
          .collection(email)
          .where('date', isEqualTo: date)
          .where('isDone', isEqualTo: false)
          .get();

      for (var task in data.docs) {
        taskList.add(Task.fromMap(task.data() as Map<String, dynamic>));
      }
      print('$taskList, $date');
      return taskList;
    } catch (e) {
      throw Exception('Gagal mendapatkan daftar tugas hari ini: $e');
    }
  }

  static Future<void> update({required Task task}) async {
    try {
      String email = _getStorage.read('email') ?? '';
      final data = _firestore.collection(email);
      await data.doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui tugas: $e');
    }
  }

  static Future<void> delete({required Task task}) async {
    try {
      String email = _getStorage.read('email') ?? '';
      final data = _firestore.collection(email);
      await data.doc(task.id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus tugas: $e');
    }
  }

  static Future<void> deleteAllRemovedTasks({List<Task>? taskList}) async {
    try {
      String email = _getStorage.read('email') ?? '';
      final data = _firestore.collection(email);
      for (var task in taskList!) {
        await data.doc(task.id).delete();
      }
    } catch (e) {
      throw Exception('Gagal menghapus semua tugas yang dihapus: $e');
    }
  }
}
