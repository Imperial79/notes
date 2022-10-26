import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes/sdp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';
import 'constants.dart';
import 'createNoteUi.dart';
import 'globalColors.dart';
import 'services/auth.dart';
import 'services/database.dart';
import 'services/globalVariable.dart';
import 'logInUI.dart';

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

    // selectedLabel == 'All'
    //     ?

    // DatabaseMethods().getAllNotes().then((value) {
    //   setState(() {
    //     noteStream = value;
    //   });
    // });
    // : DatabaseMethods()
    //     .getNotesByLabel(UserName.userName, selectedLabel)
    //     .then((value) {
    //     setState(() {
    //       noteStream = value;
    //     });
    //   });

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

        Navigator.pop(context);
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
            ? Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      snapshot.data.docs[0]['labelList'].length,
                      (index) {
                        DocumentSnapshot ds = snapshot.data.docs[0];
                        return LabelButton(ds['labelList'][index]);
                      },
                    ),
                  ),
                ),
              )
            : Container();
      },
    );
  }

  Widget NotesList() {
    return StreamBuilder<dynamic>(
      stream: DatabaseMethods.getAllNotes(),
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Padding(
                    padding: EdgeInsets.only(top: sdp(context, 90), left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                : Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: List.generate(
                        snapshot.data.docs.length,
                        (index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];

                          if (selectedLabel == 'All') {
                            return NotesCard(ds);
                          } else if (ds['label'].contains(selectedLabel)) {
                            return NotesCard(ds);
                          }
                          return SizedBox();
                        },
                      ),
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
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leadingWidth: 0,
            title: Text(
              'Notes.',
              // style: TextStyle(
              //   color: isDark ? Colors.white : Colors.black,
              //   fontSize: sdp(context, 20),
              //   fontWeight: FontWeight.w700,
              // ),
            ),
            toolbarTextStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: sdp(context, 30),
              fontWeight: FontWeight.w700,
            ),
            automaticallyImplyLeading: false,
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                GetLabelList(),
                NotesList(),
              ],
            ),
          ),
        ],
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
              NavPush(
                  context,
                  CreateNoteUi(
                    labelName: selectedLabel,
                    isEdit: false,
                  ));
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
    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedLabel = name;
          });
          selectedLabel == 'All'
              ? noteStream = DatabaseMethods.getAllNotes()
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
        child: Chip(
          padding: EdgeInsets.symmetric(horizontal: 7),
          label: Text(name),
          labelStyle: TextStyle(
            color: selectedLabel == name ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: selectedLabel == name
              ? Color.fromARGB(255, 57, 74, 206)
              : Colors.grey.shade200,
        ),
      ),
    );
    // return InkWell(
    //   onTap: () {
    // setState(() {
    //   selectedLabel = name;
    // });
    // selectedLabel == 'All'
    //     ? DatabaseMethods().getAllNotes().then((value) {
    //         setState(() {
    //           noteStream = value;
    //         });
    //       })
    //     : DatabaseMethods()
    //         .getNotesByLabel(UserName.userName, selectedLabel)
    //         .then(
    //         (value) {
    //           setState(() {
    //             noteStream = value;
    //           });
    //         },
    //       );
    //   },
    //   child: Container(
    //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //     margin: EdgeInsets.only(right: 7),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(7),
    //       color: selectedLabel == name
    //           ? Colors.orange.withOpacity(0.5)
    //           : Colors.transparent,
    //     ),
    //     child: Text(
    //       name,
    //       style: TextStyle(
    //         fontSize: selectedLabel == name ? 17 : 15,
    //         fontWeight: FontWeight.w900,
    //         color: selectedLabel == name
    //             ? Color.fromARGB(255, 231, 234, 255)
    //             : Colors.grey.shade600,
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget NotesCard(final ds) {
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
      child: GestureDetector(
        onTap: () {
          NavPush(
              context,
              // NoteContentUi(
              //   title: ds['title'],
              //   content: ds['content'],
              //   time: ds['time'],
              //   displayTime: ds['displayTime'],
              //   label: ds['label'],
              //   color: ds['color'],
              // ));

              CreateNoteUi(
                labelName: ds['label'],
                isEdit: true,
                data: ds,
              ));
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
      ),
    );
  }
}
