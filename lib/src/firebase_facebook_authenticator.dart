import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:identity/identity.dart';
import 'package:identity_firebase/identity_firebase.dart';
import 'package:sso/sso.dart';

class FirebaseFacebookAuthenticator with WillNotify implements Authenticator {
  @override
  WidgetBuilder get action => (context) => ActionButton(
      onPressed: () => authenticate(context),
      color: Color.fromRGBO(66, 103, 178, 1),
      textColor: Colors.white,
      icon: Image.asset("images/facebook.png",
          package: "identity_firebase_facebook", width: 24, height: 24),
      text: "Sign In with Facebook");

  @override
  Future<void> authenticate(BuildContext context, [Map parameters]) async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        notify(context, "Processing ...");
        return FirebaseAuth.instance
            .signInWithCredential(FacebookAuthProvider.getCredential(
                accessToken: result.accessToken.token))
            .then((result) => FirebaseProvider.convert(result.user))
            .then((user) => Identity.of(context).user = user)
            .catchError(Identity.of(context).error);
      case FacebookLoginStatus.cancelledByUser:
      case FacebookLoginStatus.error:
        Identity.of(context).error(result.errorMessage);
        break;
    }
  }
}
