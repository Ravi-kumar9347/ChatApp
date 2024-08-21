import 'package:chat_app/pages/home.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String name, profileUrl, userName;

  const ChatPage({
    super.key,
    required this.name,
    required this.profileUrl,
    required this.userName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _myUserName, _myProfilePic, _messageId, _chatRoomId;
  Stream<QuerySnapshot>? _messageStream;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _getSharedPreferences();
    await _fetchMessages();
  }

  Future<void> _getSharedPreferences() async {
    final prefs = SharedPreferenceHelper();
    _myUserName = await prefs.getUserName();
    _myProfilePic = await prefs.getUserPic();
    _chatRoomId = _getChatRoomIdByUserName(widget.userName, _myUserName!);
    setState(() {});
  }

  String _getChatRoomIdByUserName(String a, String b) {
    return a.codeUnitAt(0) > b.codeUnitAt(0) ? "${b}_$a" : "${a}_$b";
  }

  Future<void> _fetchMessages() async {
    _messageStream = await DatabaseMethods().getChatRoomMessages(_chatRoomId);
    setState(() {});
  }

  void _addMessage(bool sendClicked) {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      _messageController.clear();

      final now = DateTime.now();
      final formattedDate = DateFormat('h:mma').format(now);
      final messageInfo = {
        "message": messageText,
        "sendBy": _myUserName,
        "timeStamp": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imageUrl": _myProfilePic,
      };

      _messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(_chatRoomId!, _messageId!, messageInfo)
          .then((_) {
        final lastMessageInfo = {
          "lastMessage": messageText,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": _myUserName,
        };

        DatabaseMethods().updateLastMessageSend(_chatRoomId!, lastMessageInfo);
        if (sendClicked) {
          _messageId = null;
        }
      });
    }
  }

  Widget _chatMessageTile(String message, bool sentByMe) {
    return Row(
      mainAxisAlignment:
          sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight:
                    sentByMe ? Radius.circular(0) : Radius.circular(24.0),
                topRight: Radius.circular(24.0),
                bottomLeft:
                    sentByMe ? Radius.circular(24.0) : Radius.circular(0),
              ),
              color: sentByMe
                  ? Color.fromARGB(255, 234, 236, 240)
                  : Color.fromARGB(255, 211, 228, 243),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: _messageStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 90.0, top: 130.0),
            itemCount: messages.length,
            reverse: true,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSentByMe = _myUserName == message['sendBy'];
              return _chatMessageTile(message['message'], isSentByMe);
            },
          );
        } else {
          return Center(child: Text('No messages'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: Stack(
        children: [
          _buildChatBackground(),
          _buildAppBar(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBackground() {
    return Container(
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
      child: _buildChatMessages(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
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
          SizedBox(width: 130.0),
          Text(
            widget.name,
            style: TextStyle(
              color: Color(0xffc199cd),
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
            controller: _messageController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Type a message....!',
              hintStyle: TextStyle(color: Colors.black45),
              suffixIcon: GestureDetector(
                onTap: () => _addMessage(true),
                child: Icon(Icons.send_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
