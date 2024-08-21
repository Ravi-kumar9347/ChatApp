import 'package:chat_app/pages/chatpage.dart';
import 'package:chat_app/pages/signin.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_room_list_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isSearching = false;
  String? _myUserName;
  Stream<QuerySnapshot<Object?>>? _chatRoomsStream;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSharedPref();
    _chatRoomsStream = (await DatabaseMethods().getChatRooms());
    setState(() {});
  }

  Future<void> _loadSharedPref() async {
    _myUserName = await SharedPreferenceHelper().getUserName();
    setState(() {});
  }

  Widget _buildChatRoomList() {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: _chatRoomsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var chatRooms = snapshot.data?.docs ?? [];
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: chatRooms.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var document = chatRooms[index];
            return ChatRoomListTile(
              lastMessage: document["lastMessage"] ?? '',
              chatRoomId: document.id,
              myUserName: _myUserName ?? '',
              time: document["lastMessageSendTs"] ?? '',
            );
          },
        );
      },
    );
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _filteredResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    var capitalizedQuery = query[0].toUpperCase() + query.substring(1);

    if (_searchResults.isEmpty && query.length == 1) {
      DatabaseMethods().search(query).then((QuerySnapshot docs) {
        _searchResults
            .addAll(docs.docs.map((doc) => doc.data() as Map<String, dynamic>));
        setState(() {});
      });
    } else {
      _filteredResults = _searchResults.where((result) {
        return (result['UserName'] as String).startsWith(capitalizedQuery);
      }).toList();
      setState(() {});
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferenceHelper().clearCurrentUserData();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignIn()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, top: 50.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _isSearching
              ? Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: _handleSearch,
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
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearching = !_isSearching;
            });
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color(0xFF3a2144),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Color(0xffc199cd),
            ),
          ),
        ),
        SizedBox(width: 16),
        GestureDetector(
          onTap: _handleLogout,
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color(0xFF3a2144),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.logout,
              color: Color(0xffc199cd),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      height: _isSearching
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
          _isSearching
              ? ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  primary: false,
                  shrinkWrap: true,
                  children: _filteredResults
                      .map((result) => _buildResultCard(result))
                      .toList(),
                )
              : _buildChatRoomList(),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isSearching = false;
        });
        var chatRoomId =
            _getChatRoomIdByUserName(_myUserName!, data["UserName"] as String);
        var chatRoomInfo = {
          "users": [_myUserName, data["UserName"]]
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfo);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: data['Name'] as String,
              profileUrl: data['Photo'] as String,
              userName: data['UserName'] as String,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
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
                    data['Photo'] as String,
                    height: 60.0,
                    width: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"] as String,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      data["UserName"] as String,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getChatRoomIdByUserName(String userName1, String userName2) {
    if (userName1.substring(0, 1).codeUnitAt(0) >
        userName2.substring(0, 1).codeUnitAt(0)) {
      return "${userName2}_$userName1";
    } else {
      return "${userName1}_$userName2";
    }
  }

  final List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
}
