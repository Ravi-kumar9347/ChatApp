import 'package:chat_app/pages/chatpage.dart';
import 'package:chat_app/service/database.dart';
import 'package:flutter/material.dart';

class ChatRoomListTile extends StatefulWidget {
  final String chatRoomId;
  final String lastMessage;
  final String time;
  final String myUserName;

  const ChatRoomListTile({
    super.key,
    required this.chatRoomId,
    required this.lastMessage,
    required this.time,
    required this.myUserName,
  });

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String _profilePicUrl = "";
  String _name = "";
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    _userName =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUserName, "");
    var querySnapshot =
        await DatabaseMethods().getUserInfo(_userName.toUpperCase());
    if (querySnapshot.docs.isNotEmpty) {
      var userData = querySnapshot.docs[0].data() as Map<String, dynamic>;
      setState(() {
        _name = userData["Name"] ?? '';
        _profilePicUrl = userData["Photo"] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: _name,
              profileUrl: _profilePicUrl,
              userName: _userName,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profilePicUrl.isEmpty
                ? CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      _profilePicUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
            SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  _userName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(
                    widget.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              widget.time,
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
