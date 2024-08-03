import 'package:chat_app/pages/home.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  String name, profileUrl, userName;
  ChatPage(
      {required this.name, required this.profileUrl, required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = new TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  getTheSharedPref() async {
    myUserName = await SharedPreferenceHelper().getUserName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    chatRoomId = getChatRoomIdByUserName(widget.userName, myUserName!);
    setState(() {});
  }

  onTheLoad() async {
    await getTheSharedPref();
    await getAndSetMessages();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight:
                    sendByMe ? Radius.circular(0) : Radius.circular(24.0),
                topRight: Radius.circular(24.0),
                bottomLeft:
                    sendByMe ? Radius.circular(24.0) : Radius.circular(0),
              ),
              color: sendByMe
                  ? Color.fromARGB(255, 234, 236, 240)
                  : Color.fromARGB(255, 211, 228, 243),
            ),
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 90.0, top: 130.0),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data.docs[index];
                    return chatMessageTile(documentSnapshot['message'],
                        myUserName == documentSnapshot['sendBy']);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  addMessage(bool sendClicked) {
    if (messageController.text.isNotEmpty) {
      String message = messageController.text;
      messageController.text = "";

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "timeStamp": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imageUrl": myProfilePic,
      };

      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
        };

        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: Container(
        margin: EdgeInsets.only(
          top: 50.0,
        ),
        child: Stack(
          children: [
            Container(
                margin: EdgeInsets.only(top: 50.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: chatMessage()),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Color(0xffc199cd),
                    ),
                  ),
                  SizedBox(
                    width: 130.0,
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                        color: Color(0xffc199cd),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message....!",
                      hintStyle: TextStyle(
                        color: Colors.black45,
                      ),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            addMessage(true);
                          },
                          child: Icon(Icons.send_rounded)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
