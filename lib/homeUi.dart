import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Functions/functions.dart';
import 'createNoteUi.dart';
import 'editNoteContentUi.dart';
import 'globalColors.dart';
import 'services/auth.dart';
import 'services/database.dart';
import 'services/globalVariable.dart';
import 'signInUi.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({Key? key}) : super(key: key);

  @override
  _HomeUiState createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  DarkColors darkColors = new DarkColors();
  Stream? noteStream;
  Stream? labelStream;
  TextEditingController newLabelName = new TextEditingController();
  QuerySnapshot<Map<String, dynamic>>? labelListDB;
  String selectedLabel = 'All';
  List? labelList;
  final formKey = GlobalKey<FormState>();

  NoteColors noteColors = new NoteColors();

  @override
  void initState() {
    onPageLoad();
    super.initState();
  }

  onPageLoad() async {
    if (UserName.userName == '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      UserName.userName = prefs.getString('USERNAMEKEY')!;
      UserName.userEmail = prefs.getString('USEREMAILKEY')!;
      UserName.userId = prefs.getString('USERKEY')!;
      UserName.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
      UserName.userProfilePic = prefs.getString('USERPROFILEKEY')!;
      setState(() {});
    }

    selectedLabel == 'All'
        ? DatabaseMethods().getAllNotes().then((value) {
            setState(() {
              noteStream = value;
            });
          })
        : DatabaseMethods()
            .getNotesByLabel(UserName.userName, selectedLabel)
            .then((value) {
            setState(() {
              noteStream = value;
            });
          });

    DatabaseMethods().getlabel().then((value) {
      setState(() {
        labelListDB = value;
      });
    });

    DatabaseMethods().fetchLabel().then((value) {
      setState(() {
        labelStream = value;
      });
    });
  }

  newLabel() async {
    if (formKey.currentState!.validate()) {
      await DatabaseMethods().getlabel().then((value) {
        setState(() {
          labelListDB = value;
        });
      });

      labelList = labelListDB!.docs[0].data()['labelList'];
      // print(labelList);
      if (!labelList!.contains(newLabelName.text)) {
        labelList!.add(newLabelName.text);
        var labelSet = labelList!.toSet();
        labelList = labelSet.toList();

        DatabaseMethods().updatelabel(labelList!);
        PageRouteTransition.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.indigo,
            duration: Duration(seconds: 1),
            content: Text(
              'Label Already exist',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
    newLabelName.clear();
  }

  deleteANote(String time, String labelName) async {
    await DatabaseMethods().deleteNote(UserName.userName, time, labelName);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 1),
        content: Text(
          'Note Deleted',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget GetLabelList() {
    return StreamBuilder<dynamic>(
      stream: labelStream,
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? Row(
                children: List.generate(
                  snapshot.data.docs[0]['labelList'].length,
                  (index) {
                    DocumentSnapshot ds = snapshot.data.docs[0];
                    return LabelButton(ds['labelList'][index]);
                  },
                ),
              )
            : Container();
      },
    );
  }

  Widget NotesList() {
    return StreamBuilder<dynamic>(
      stream: noteStream,
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create Notes',
                          style: TextStyle(
                            fontSize: 37,
                            color: Color.fromARGB(255, 112, 112, 112),
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'to get Started',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 112, 112, 112),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(
                      snapshot.data.docs.length,
                      (index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return Dismissible(
                          background: Text(
                            'Delete this ...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            deleteANote(ds['time'], ds['label']);
                          },
                          child: NotesCard(ds),
                        );
                      },
                    ),
                  )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.height * 0.04,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade600,
                              radius: 20,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: UserName.userProfilePic == ''
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Image.network(
                                        UserName.userProfilePic,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Container(
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     physics: BouncingScrollPhysics(),
                      //     child: GetLabelList(),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Stack(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: NotesList(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                color: Colors.black.withOpacity(0.4),
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  child: GetLabelList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        spaceBetweenChildren: 20,
        useRotationAnimation: true,
        activeIcon: Icons.close,
        backgroundColor: Colors.blueGrey.shade200,
        elevation: 0,
        buttonSize: Size(60, 60),
        animationSpeed: 200,
        childrenButtonSize: Size(70, 70),
        icon: Icons.add,
        overlayColor: Colors.white,
        children: [
          SpeedDialChild(
            onTap: () {
              PageRouteTransition.push(
                  context,
                  CreateNoteUi(
                    labelName: selectedLabel,
                  )).then((value) {
                setState(() {});
              });
            },
            child: Icon(Icons.note_add),
            labelWidget: Text(
              'New Note     ',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
          ),
          SpeedDialChild(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return NewLabelDialogBox();
                },
              );
            },
            child: Icon(Icons.new_label),
            labelWidget: Text(
              'New Label      ',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.blueGrey.shade800,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    bottom: 15,
                    top: 50,
                    left: 15,
                  ),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 10,
                    ),
                  ),
                  child: UserName.userProfilePic == ''
                      ? CircularProgressIndicator(
                          color: Colors.grey.shade700,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            UserName.userProfilePic,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    UserName.userDisplayName.replaceAll(' ', '\n'),
                    style: TextStyle(
                      fontSize: size.height * 0.03,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.05),
                child: MaterialButton(
                  onPressed: () async {
                    AuthMethods().signOut();
                    PageRouteTransition.pushReplacement(context, SignInUi());

                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    await preferences.clear();
                  },
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  color: Colors.red,
                  child: Container(
                    height: 45,
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'SIGN OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
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

  StatefulBuilder NewLabelDialogBox() {
    return StatefulBuilder(
      builder: (context, setState) {
        return SimpleDialog(
          backgroundColor: Color.fromARGB(255, 82, 82, 82),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Create label',
            style: TextStyle(
              color: Color.fromARGB(255, 221, 221, 221),
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Form(
              key: formKey,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 95, 95, 95),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  controller: newLabelName,
                  cursorColor: Colors.white,
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w600,
                    fontSize: 16.5,
                  ),
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red.shade300,
                    ),
                    border: InputBorder.none,
                    hintText: 'Label name',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value!.length > 15 || value.isEmpty) {
                      return 'Length must not be more than 15 characters';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: MaterialButton(
                onPressed: () {
                  newLabel();
                },
                padding: EdgeInsets.all(10),
                color: Colors.blueGrey.shade200,
                elevation: 0,
                highlightElevation: 0,
                child: Container(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          elevation: 0,
        );
      },
    );
  }

  Widget LabelButton(String name) {
    int nameLength = name.length;
    return Padding(
      padding: EdgeInsets.only(right: 7),
      child: MaterialButton(
        onPressed: () {
          setState(() {
            selectedLabel = name;
          });
          selectedLabel == 'All'
              ? DatabaseMethods().getAllNotes().then((value) {
                  setState(() {
                    noteStream = value;
                  });
                })
              : DatabaseMethods()
                  .getNotesByLabel(UserName.userName, selectedLabel)
                  .then(
                  (value) {
                    setState(() {
                      noteStream = value;
                    });
                  },
                );
        },
        elevation: 0,
        highlightElevation: 0,
        color: selectedLabel == name
            ? Colors.orange.withOpacity(0.5)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(
            color: selectedLabel == name
                ? Colors.transparent
                : Colors.grey.shade600,
            width: 1,
          ),
        ),
        child: Container(
          child: Text(
            name,
            style: TextStyle(
              fontSize: selectedLabel == name ? 17 : 15,
              fontWeight: FontWeight.w900,
              color: selectedLabel == name
                  ? Color.fromARGB(255, 231, 234, 255)
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget NotesCard(final ds) {
    return GestureDetector(
      onTap: () {
        PageRouteTransition.push(
            context,
            NoteContentUi(
              title: ds['title'],
              content: ds['content'],
              time: ds['time'],
              displayTime: ds['displayTime'],
              label: ds['label'],
              color: ds['color'],
            )).then((value) {
          setState(() {});
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          // color: color,
          color: noteColors.colorPallete[ds['color']]['bg'],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ds['title'] == '' ? 'no title' : ds['title'],
              style: TextStyle(
                color: ds['title'] == ''
                    ? noteColors.colorPallete[ds['color']]['hintText']
                    : noteColors.colorPallete[ds['color']]['text'],
                fontWeight: FontWeight.w900,
                fontSize: 22,
                fontStyle:
                    ds['title'] == '' ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              ds['content'] == '' ? 'no content' : ds['content'],
              style: TextStyle(
                color: ds['content'] == ''
                    ? noteColors.colorPallete[ds['color']]['hintText']
                    : noteColors.colorPallete[ds['color']]['text'],
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontStyle:
                    ds['content'] == '' ? FontStyle.italic : FontStyle.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 15,
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.black,
              ),
              child: Text(
                ds['displayTime'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
