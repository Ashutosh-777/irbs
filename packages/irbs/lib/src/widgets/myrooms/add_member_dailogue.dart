import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:irbs/src/store/room_detail_store.dart';
import 'package:provider/provider.dart';
import '../../globals/colors.dart';
import '../../globals/styles.dart';
import '../../services/api.dart';



Future<void> addMemberDialog(BuildContext rootContext) async {
  return showDialog(
      barrierDismissible: false,
      context: rootContext,
      builder: (context) {
        return AddMemberDailogue(rootContext: rootContext);
      });
}

class AddMemberDailogue extends StatefulWidget {
  final BuildContext rootContext;
  const AddMemberDailogue({super.key,required this.rootContext});

  @override
  State<AddMemberDailogue> createState() => _AddMemberDailogueState();
}

class _AddMemberDailogueState extends State<AddMemberDailogue> {
  TextEditingController emailCtl = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool checkAdmin = true;
  bool apiCall = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var rd = widget.rootContext.read<RoomDetailStore>();
    return Form(
      key: _formkey,
      child: SimpleDialog(
        backgroundColor: const Color.fromRGBO(39, 49, 65, 1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(
            height: 12,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 0.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                )),
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            height: 24,
            child: Text(
              'Add Member',
              style: appBarStyle.copyWith(
                  color: Themes.myRoomsFormHeadingColor, fontSize: 18),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          TextFormField(
              controller: emailCtl,
              validator: (value) {
                if (value == null || value == '') return 'Enter Email';
                if (!value.endsWith('@iitg.ac.in')) {
                  return 'Email should be IITG Mail Id';
                }
                if (rd.currentRoom.owner.contains(value) ||
                    rd.currentRoom.allowedUsers.contains(value)) {
                  return 'Already a Member';
                }
                return null;
              },
              style: permanentTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: textFieldDecoration.copyWith(
                  labelText: "Mail ID", labelStyle: labelTextStyle)),
          const SizedBox(
            height: 18,
          ),
          CheckboxListTile(
              value: checkAdmin,
              title: Text(
                'Admin',
                style: popupMenuStyle.copyWith(fontSize: 14),
              ),
              onChanged: (bool? value) {
                setState(() {
                  checkAdmin = value!;
                });
              }),
          const SizedBox(
            height: 18,
          ),
          Container(
            height: 48,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(118, 172, 255, 1),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: InkWell(
                onTap: () async {
                  if (_formkey.currentState!.validate() == false) {
                    return;
                  } else {
                    if (!apiCall) {
                      setState(() {
                        apiCall = true;
                      });
                      List<String> x = checkAdmin
                          ? List<String>.of(rd.currentRoom.owner)
                          : List<String>.of(rd.currentRoom.allowedUsers);
                      x.add(emailCtl.text);
                      String s = checkAdmin ? "owner" : "allowedUsers";
                      var details = jsonEncode({s: x});

                      try{
                     var res = await APIService().editRoomDetails(rd.currentRoom.id, details);
                     print(res);
                     rd.updateRoom(res);
                     Navigator.pop(context);
                      }
                  catch(e){
                    setState(() {
                      apiCall = false;
                    });
                    print("THIS WAS THE ERROR");
                    Fluttertoast.showToast(msg: 'Email Invalid', backgroundColor: Colors.white, textColor: Colors.black);
                    print(rd.currentRoom.owner);
                    print(rd.currentRoom.allowedUsers);
                    Navigator.pop(context);
                  }
                    }
                  }
                },
                child: Center(
                    child: (apiCall)
                        ? const CircularProgressIndicator()
                        : const Text(
                      'Add',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          package: 'irbs',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ))),
          ),
          const SizedBox(
            height: 18,
          )
        ],
      ),
    );
  }
}