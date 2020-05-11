import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';


class FirebaseServ {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final Firestore _fireDb = Firestore.instance;

  Future<bool> signIn(String email, String password) async {
    AuthResult result;
    // FirebaseUser user;
    try{
    	result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    	// user = result.user;
      return result != null ? true : false;
    }catch(e){
    	print('FirebaseServ exception: $e');
      return false;
    }
  }

  Future<String> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if(user != null){
    	return user.email;
    }else{
    	return null;
    }	
  }

  Future<bool> signOut() async {
  	try{
  		await _firebaseAuth.signOut();
  		return true;
  	}catch(e){
  		print(e.toStirng());
  		return false;
  	}
  }

}

FirebaseServ fServ = new FirebaseServ();

