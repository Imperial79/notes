import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'globalColors.dart';
import 'services/database.dart';
import 'services/globalVariable.dart';

class CreateNoteUi extends StatefulWidget {
  String labelName;
  CreateNoteUi({
    required this.labelName,
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

  NoteColors noteColors = new NoteColors();

  @override
  void initState() {
    var formatter = DateFormat('dd MMMM, yyyy').format(DateTime.now());
    displayTime = formatter;
    super.initState();
  }

  saveNote(var DisplayTime, String currTime) {
    String savedCurrTime = currTime;
    if (titleController.text.isEmpty && contentController.text.isEmpty) {
      Navigator.pop(context);
    } else {
      Map<String, String> noteMap = {
        'title': titleController.text,
        'content': contentController.text,
        'time': savedCurrTime,
        'displayTime': DisplayTime,
        'label': widget.labelName,
        'color': selectedColor,
      };
      // print(widget.labelName);
      DatabaseMethods().uploadNotes(
          UserName.userName, noteMap, widget.labelName, savedCurrTime);
      Navigator.pop(context);
      titleController.clear();
      contentController.clear();
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
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness:
            selectedColor == 'white' || selectedColor == 'orange'
                ? Brightness.dark
                : Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: noteColors.colorPallete[selectedColor]['bg'],
      body: WillPopScope(
        onWillPop: () {
          var formatter =
              DateFormat('dd MMMM, yyyy | ').add_jm().format(DateTime.now());
          String currentTime = DateTime.now().toString();

          return saveNote(formatter, currentTime);
        },
        child: SafeArea(
          bottom: false,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    var formatter = DateFormat('dd MMMM, yyyy | ')
                        .add_jm()
                        .format(DateTime.now());
                    String currentTime = DateTime.now().toString();

                    return saveNote(formatter, currentTime);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 20),
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: noteColors.colorPallete[selectedColor]['text'],
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: noteColors.colorPallete[selectedColor]['text'],
                      size: 20,
                    ),
                  ),
                ),
                TextFormField(
                  controller: titleController,
                  cursorColor: noteColors.colorPallete[selectedColor]['text'],
                  style: TextStyle(
                    fontSize: 25,
                    color: noteColors.colorPallete[selectedColor]['text'],
                    fontWeight: FontWeight.w800,
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 13),
                  decoration: BoxDecoration(
                    color: noteColors.colorPallete[selectedColor]['labelCard'],
                  ),
                  child: Text(
                    'LABEL: ' + widget.labelName,
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: contentController,
                    cursorColor: noteColors.colorPallete[selectedColor]['text'],
                    style: TextStyle(
                      fontSize: 18,
                      color: noteColors.colorPallete[selectedColor]['text'],
                      fontWeight: FontWeight.w500,
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
                  ),
                ),
                MediaQuery.of(context).viewInsets.bottom == 0
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  showModalBottomSheet(
                                    // isScrollControlled: true,
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
                                icon: Icon(
                                  Icons.palette,
                                  color: noteColors.colorPallete[selectedColor]
                                      ['text'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ColorSheet(Size size) {
    return StatefulBuilder(
      builder: (context, StateSetter setModalState) {
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: noteColors.colorPallete[selectedColor]['bg'],
            borderRadius: BorderRadius.circular(15),
          ),
          height: size.height * 0.165,
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    List.generate(noteColors.colorPallete.keys.length, (index) {
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
                      text: displayTime,
                      style: TextStyle(
                        color: noteColors.colorPallete[selectedColor]['text'],
                        fontWeight: FontWeight.w700,
                        fontSize: size.height * 0.017,
                      ),
                    ),
                    TextSpan(
                      text: ' | ',
                      style: TextStyle(
                        color: noteColors.colorPallete[selectedColor]['text'],
                        fontWeight: FontWeight.w700,
                        fontSize: size.height * 0.019,
                      ),
                    ),
                    TextSpan(
                      text: contentController.text.length.toString() + ' words',
                      style: TextStyle(
                        color: noteColors.colorPallete[selectedColor]['text'],
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
    );
  }

  Widget buildColorSwatch(String colorKey) {
    Size size = MediaQuery.of(context).size;
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
