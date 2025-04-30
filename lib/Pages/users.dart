import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/Widgets/UserCard.dart';
import 'package:eppser/Widgets/UserCard2.dart';
import 'package:flutter/material.dart';

class usersPage extends StatefulWidget {
  final snap;
  const usersPage({super.key, this.snap});

  @override
  State<usersPage> createState() => _usersPageState();
}

class _usersPageState extends State<usersPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  bool isLoading = false;
  var userData;
  List followers = [];
  var following;
  var isFollowing;
  var tick;
  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snap)
          .get();
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'];
      following = userSnap.data()!['following'];
      tick = userData['tick'];

      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              title: TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Takip"),
                    Tab(
                      text: "Takipçi",
                    )
                  ]),
            ),
            body: TabBarView(controller: _tabController, children: [
              ListView.builder(
                itemCount: following.length,
                itemBuilder: (context, index) {
                  return userCard(
                    snap: following[index],
                  );
                },
              ),
              ListView.builder(
                itemCount: followers.length,
                itemBuilder: (context, index) {
                  return userCard2(
                    uid: widget.snap,
                    snap: followers[index],
                  );
                },
              ),
            ]));
  }
}
