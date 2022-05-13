import 'package:shared_preferences/shared_preferences.dart';

import '../services/globalVariable.dart';

getUserDetailsFromPreference() async {
  if (UserName.userName == '') {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserName.userName = prefs.getString('USERNAMEKEY')!;
    UserName.userEmail = prefs.getString('USEREMAILKEY')!;
    UserName.userId = prefs.getString('USERKEY')!;
    UserName.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
    UserName.userProfilePic = prefs.getString('USERPROFILEKEY')!;
  }
}
