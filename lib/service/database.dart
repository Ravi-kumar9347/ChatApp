import 'package:chat_app/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _getDocReference(String collection, String docId) {
    return _firestore.collection(collection).doc(docId);
  }

  CollectionReference _getCollectionReference(String collection) {
    return _firestore.collection(collection);
  }

  Future<void> addUserDetails(
      Map<String, dynamic> userInfoMap, String id) async {
    return await _getDocReference("users", id).set(userInfoMap);
  }

  Future<QuerySnapshot> getUserByEmail(String email) async {
    return await _getCollectionReference("users")
        .where("E-mail", isEqualTo: email)
        .get();
  }

  Future<QuerySnapshot> search(String userName) async {
    return await _getCollectionReference("users")
        .where("SearchKey", isEqualTo: userName.substring(0, 1).toUpperCase())
        .get();
  }

  Future<bool> createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await _getDocReference("chatrooms", chatRoomId).get();
    if (snapshot.exists) {
      return true;
    } else {
      await _getDocReference("chatrooms", chatRoomId).set(chatRoomInfoMap);
      return false;
    }
  }

  Future<void> addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return await _getDocReference("chatrooms", chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future<void> updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) async {
    return await _getDocReference("chatrooms", chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(String? chatRoomId) async {
    return _getDocReference("chatrooms", chatRoomId!)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String userName) async {
    return await _getCollectionReference("users")
        .where("UserName", isEqualTo: userName)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUserName = await SharedPreferenceHelper().getUserName();
    if (myUserName == null) {
      throw Exception("User name not found");
    }
    return _getCollectionReference("chatrooms")
        .orderBy("time", descending: true)
        .where("users", arrayContains: myUserName)
        .snapshots();
  }
}
