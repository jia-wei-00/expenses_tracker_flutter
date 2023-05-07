import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

part 'firestore_state.dart';

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit() : super(FirestoreInitial());

  final db = FirebaseFirestore.instance;

  String getMonth() {
    DateTime now = DateTime.now();
    return DateFormat('MMMM yyyy').format(now);
  }

  Future<void> fetchData(User user) async {
    emit(FirestoreLoading());
    try {
      final querySnapshot = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(getMonth())
          .orderBy("timestamp", descending: true)
          .snapshots()
          .first;
      final List<Expense> payload = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Expense(
          id: doc.id,
          amount: data['amount'].toString(),
          name: data['name'],
          type: data['type'],
          category: data['category'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
      emit(FirestoreRecordLoaded(expenses: payload));
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }

// export function postRecord(payload) {
//   return (dispatch) => {
//     const id = toast.loading("Please wait...");
//     dispatch(setLoading(true));

//     db.collection("expense__tracker")
//       .doc(payload.user)
//       .collection(payload.date)
//       .add({
//         type: payload.type,
//         name: payload.name,
//         amount: payload.amount,
//         category: payload.category,
//         timestamp: payload.timestamp,
//       })
//       .then((success) => {
//         toast.update(id, {
//           render: "Successfully Add Data",
//           type: "success",
//           isLoading: false,
//           autoClose: 5000,
//         });
//         dispatch(setLoading(false));
//       })
//       .catch((error) => {
//         toast.update(id, {
//           render: error.message,
//           type: "error",
//           isLoading: false,
//           autoClose: 5000,
//         });
//         dispatch(setLoading(false));
//       });
//   };
// }
}
