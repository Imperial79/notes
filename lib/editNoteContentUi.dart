import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/services/globalVariable.dart';

import 'globalColors.dart';
import 'services/database.dart';

class NoteContentUi extends StatefulWidget {
  String title, content, displayTime, label, time, color;
  NoteContentUi({
    required this.content,
    required this.title,
    required this.time,
    required this.displayTime,
    required this.label,
    required this.color,
  });

  @override
  _NoteContentUiState createState() => _NoteContentUiState();
}

class _NoteContentUiState extends State<NoteContentUi> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String selectedColor = '';
  NoteColors noteColors = new NoteColors();

  updateNote() async {
    // String updatedTime = DateTime.now().toString();

    if (widget.content != contentController.text ||
        widget.title != titleController.text ||
        selectedColor != widget.color) {
      Map<String, dynamic> updatedNoteMap = {
        'title': titleController.text,
        'content': contentController.text,
        'displayTime': widget.displayTime,
        'time': widget.time,
        'label': widget.label,
        'color': selectedColor,
      };
      Navigator.pop(context);
      await DatabaseMethods().updateNote(widget.time, updatedNoteMap);
    } else {
      Navigator.pop(context);
    }
  }

  deleteANote(String time, String labelName) async {
    Navigator.pop(context);
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
    await DatabaseMethods().deleteNote(UserName.userName, time, labelName);
    setState(() {});
  }

  @override
  void initState() {
    titleController.text = widget.title;
    contentController.text = widget.content;
    selectedColor = widget.color;
    super.initState();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 20),
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: noteColors.colorPallete[selectedColor]
                                ['text'],
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: noteColors.colorPallete[selectedColor]['text'],
                          size: size.height * 0.023,
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  autofocus: false,
                  controller: titleController,
                  cursorColor: noteColors.colorPallete[selectedColor]['text'],
                  style: TextStyle(
                    fontSize: 25,
                    color: noteColors.colorPallete[selectedColor]['text'],
                    fontWeight: FontWeight.w800,
                  ),
                  keyboardType: TextInputType.text,
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
                    'LABEL: ' + widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    cursorColor: Colors.blueGrey,
                    controller: contentController,
                    style: TextStyle(
                      fontSize: 18,
                      color: noteColors.colorPallete[selectedColor]['text'],
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 18,
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
                              radius: 23,
                              backgroundColor: Colors.grey.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    context: context,
                                    builder: (builder) {
                                      return colorSheet(size);
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.palette,
                                  size: 20,
                                  color: noteColors.colorPallete[selectedColor]
                                      ['text'],
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 23,
                              backgroundColor: Colors.grey.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  deleteANote(widget.time, widget.label);
                                },
                                icon: Icon(
                                  Icons.delete,
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

  Widget colorSheet(Size size) {
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
                children: List.generate(
                  noteColors.colorPallete.keys.length,
                  (index) => buildColorSwatch(
                    noteColors.colorPallete.keys.elementAt(index),
                    setModalState,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.displayTime,
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

  Widget buildColorSwatch(String colorKey, StateSetter setModalState) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            selectedColor = colorKey;
          });
          setState(() {});
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
