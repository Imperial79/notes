import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:notes/constants.dart';
import 'package:notes/sdp.dart';

import 'globalColors.dart';
import 'services/database.dart';
import 'services/globalVariable.dart';

class CreateNoteUi extends StatefulWidget {
  final labelName;
  final bool isEdit;
  final DocumentSnapshot? data;
  CreateNoteUi({
    required this.labelName,
    required this.isEdit,
    this.data,
  });

  @override
  _CreateNoteUiState createState() => _CreateNoteUiState();
}

class _CreateNoteUiState extends State<CreateNoteUi> {
  TextEditingController titleController = new TextEditingController();
  TextEditingController contentController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? displayTime;
  LightColors lightColors = new LightColors();
  DarkColors darkColors = new DarkColors();
  String selectedColor = 'black';
  String inFocus = 'title';
  String savedCurrTime = DateTime.now().toString();

  NoteColors noteColors = new NoteColors();

  @override
  void initState() {
    if (widget.isEdit) {
      titleController.text = widget.data!['title'];
      contentController.text = widget.data!['content'];
      savedCurrTime = widget.data!['time'];
      selectedColor = widget.data!['color'];
    }
    super.initState();
  }

  updateNote() {
    if (widget.data!['title'] != titleController.text ||
        widget.data!['content'] != contentController.text) {
      Map<String, String> noteMap = {
        'title': titleController.text,
        'content': contentController.text,
        'time': savedCurrTime,
        'displayTime':
            DateFormat('dd MMMM, yyyy').format(DateTime.parse(savedCurrTime)),
        'label': widget.labelName,
        'color': selectedColor,
      };
      // print(widget.labelName);
      DatabaseMethods().uploadNotes(
          UserName.userName, noteMap, widget.labelName, savedCurrTime);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  saveNote(var DisplayTime, String currTime) {
    if (!widget.isEdit) {
      savedCurrTime = currTime;
    }
    if (titleController.text.isEmpty && contentController.text.isEmpty) {
      Navigator.pop(context);
    } else {
      Map<String, String> noteMap = {
        'title': titleController.text,
        'content': contentController.text,
        'time': savedCurrTime,
        'displayTime':
            DateFormat('dd MMMM, yyyy').format(DateTime.parse(currTime)),
        'label': widget.labelName,
        'color': selectedColor,
      };

      DatabaseMethods().uploadNotes(
          UserName.userName, noteMap, widget.labelName, savedCurrTime);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Row(
            children: [
              Icon(
                Icons.save_rounded,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Note Saved",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          if (!widget.isEdit) {
            var formatter =
                DateFormat('dd MMMM, yyyy | ').add_jm().format(DateTime.now());
            String currentTime = DateTime.now().toString();

            return saveNote(formatter, currentTime);
          }
          return updateNote();
        },
        child: SafeArea(
          bottom: false,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        var formatter = DateFormat('dd MMMM, yyyy | ')
                            .add_jm()
                            .format(DateTime.now());
                        String currentTime = DateTime.now().toString();

                        return saveNote(formatter, currentTime);
                      },
                      icon: Icon(
                        Icons.close,
                        // color: noteColors.colorPallete[selectedColor]['text'],
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 13),
                        decoration: BoxDecoration(
                          color: noteColors.colorPallete[selectedColor]
                              ['labelCard'],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          widget.labelName,
                          style: TextStyle(
                            color: Colors.white,
                            // fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  onTap: () {
                    setState(() {
                      inFocus = 'title';
                    });
                  },
                  controller: titleController,
                  // cursorColor: noteColors.colorPallete[selectedColor]['text'],
                  cursorColor: isDark ? Colors.white : Colors.black,
                  style: TextStyle(
                    fontSize: sdp(context, 30),
                    // color: noteColors.colorPallete[selectedColor]['text'],
                    color: isDark ? Colors.white : Colors.black,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w800,
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: inFocus == 'title' ? 2 : 1,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: noteColors.colorPallete[selectedColor]['hintText'],
                    ),
                  ),
                  validator: (value) {
                    if (value!.length > 50) {
                      return 'Title must be less than 50 characters';
                    }
                    return null;
                  },
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                        horizontal: contentController.text.isEmpty ? 10 : 0),
                    decoration: BoxDecoration(
                      // color: isDark ? Colors.grey : Colors.grey.shade100,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          noteColors.colorPallete[selectedColor]['labelCard']
                              .withOpacity(0.005),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      onTap: () {
                        setState(() {
                          inFocus = 'content';
                        });
                      },
                      controller: contentController,
                      // cursorColor: noteColors.colorPallete[selectedColor]
                      //     ['text'],
                      cursorColor: isDark ? Colors.white : Colors.black,
                      style: TextStyle(
                        fontSize: 18,
                        // color: noteColors.colorPallete[selectedColor]['text'],
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 17,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                        hintText: 'Note...',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: noteColors.colorPallete[selectedColor]
                              ['hintText'],
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return ColorSheet(size);
                  },
                );
              },
              elevation: 0,
              backgroundColor: noteColors.colorPallete[selectedColor]
                  ['labelCard'],
              child: Icon(
                Icons.colorize,
                color: noteColors.colorPallete[selectedColor]['text'],
              ),
            )
          : null,
    );
  }

  Widget ColorSheet(Size size) {
    return SafeArea(
      child: StatefulBuilder(
        builder: (context, StateSetter setModalState) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              // color: noteColors.colorPallete[selectedColor]['bg'],
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            height: sdp(context, 100),
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(noteColors.colorPallete.keys.length,
                      (index) {
                    final colorKey =
                        noteColors.colorPallete.keys.elementAt(index);
                    return Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedColor = colorKey;
                            print(selectedColor);
                          });

                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: noteColors.colorPallete[colorKey]
                              ['bg'],
                          child: selectedColor == colorKey
                              ? Icon(
                                  Icons.done,
                                  color: selectedColor == 'white' ||
                                          selectedColor == 'orange'
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : Container(),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            DateFormat('dd MMMM, yyyy').format(DateTime.now()),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: size.height * 0.017,
                        ),
                      ),
                      TextSpan(
                        text: ' | ',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: size.height * 0.019,
                        ),
                      ),
                      TextSpan(
                        text:
                            contentController.text.length.toString() + ' words',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: size.height * 0.017,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildColorSwatch(String colorKey) {
    return Padding(
      padding: EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = colorKey;
          });
        },
        child: CircleAvatar(
          radius: 20,
          backgroundColor: noteColors.colorPallete[colorKey]['bg'],
          child: selectedColor == colorKey
              ? Icon(
                  Icons.done,
                  color: selectedColor == 'white' || selectedColor == 'orange'
                      ? Colors.black
                      : Colors.white,
                )
              : Container(),
        ),
      ),
    );
  }
}
