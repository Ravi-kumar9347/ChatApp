import 'package:chat_app/pages/chatpage.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomsStream;

  getTheSharedPref() async {
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  onTheLoad() async {
    await getTheSharedPref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                  return ChatRoomListTile(
                      lastMessage: documentSnapshot["lastMessage"],
                      chatRoomId: documentSnapshot.id,
                      myUserName: myUserName!,
                      time: documentSnapshot["lastMessageSendTs"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
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

  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; i++) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['UserName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 50.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search
                      ? Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) {
                              initiateSearch(value.toUpperCase());
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search User",
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      : Text(
                          "ChatApp",
                          style: TextStyle(
                              color: Color(0xffc199cd),
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        ),
                  GestureDetector(
                    onTap: () {
                      search = true;
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Color(0xFF3a2144),
                          borderRadius: BorderRadius.circular(20)),
                      child: search
                          ? GestureDetector(
                              onTap: () {
                                search = false;
                                setState(() {});
                              },
                              child: Icon(
                                Icons.close,
                                color: Color(0xffc199cd),
                              ),
                            )
                          : Icon(
                              Icons.search,
                              color: Color(0xffc199cd),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              height: search
                  ? MediaQuery.of(context).size.height / 1.19
                  : MediaQuery.of(context).size.height / 1.15,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  search
                      ? ListView(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          primary: false,
                          shrinkWrap: true,
                          children: tempSearchStore.map((element) {
                            return buildResultCard(element);
                          }).toList())
                      : chatRoomList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});
        var chatRoomId = getChatRoomIdByUserName(myUserName!, data["UserName"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["UserName"]],
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: data['Name'],
                    profileUrl: data['Photo'],
                    userName: data['UserName'])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            padding: EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60.0),
                  child: Image.network(
                    data['Photo'],
                    height: 60.0,
                    width: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      data["UserName"],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUserName, time;
  ChatRoomListTile(
      {required this.lastMessage,
      required this.chatRoomId,
      required this.myUserName,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", userName = "", id = "";

  getThisUserInfo() async {
    userName =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUserName, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(userName.toUpperCase());
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
                name: name, profileUrl: profilePicUrl, userName: userName),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicUrl == ""
                ? CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      profilePicUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
            SizedBox(
              width: 12.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  userName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w500),
                ),
                Container(
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
