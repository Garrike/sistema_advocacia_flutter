//import 'dart:js';
//import 'package:firebase/firebase.dart' as fb;
//import 'package:firebase/firestore.dart' as fs;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:projetoPDS/home_screen.dart';
import 'package:projetoPDS/login_screen.dart';

import 'models/arquivos.dart';
import 'models/user.dart';

class AuthService {
  //Handle Authentication
  handleAuth() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }

  //Get currently logged-in user
  Future<User> currentUser() async {
    var user = User();
    var userJson;
    try{
      final response = await http.get(
        'https://projetopds-72fa1.firebaseapp.com/api/v1/contacts'
      );
      // print(response.body);
      // print('\n\n');
      await FirebaseAuth.instance.currentUser().then((user) {
        userJson = json.decode(response.body)['usuarios'][user.uid];
        // print(userJson);
        
      });
    } catch(e) {
      return null;
    }
    if(userJson != null){
      user = User(
        email: userJson['email'],
        password: userJson['password'],
        name: userJson['name'],
        office: userJson['office'],
        userid: userJson['userid'],
        processes: userJson['processes'],
        pending: userJson['pending']
      );
    }
    // print('\n\n');
    // print(user.name);
    // print('\n\n');
    return user;
  }

  //Sign out
  Future signOut() async {
    FirebaseAuth.instance.signOut();
  }
  
  //Sign in
  Future signIn(email, password) async {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) {
    }).catchError((e) {
      // print('error..');
      print(e);
    });
  }

  //Create User
  Future createUser(email, password, name, office) async {
    
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((data){
      addUser(email, password, name, office, data.user.uid);

      //Here if you want you can sign in the user
    }).catchError((e) {
      print(e);
      return false;
    });

    return true;
  }

  addUser(email, password, name, office, userid) async {
    var resBody = {};
    resBody["email"] = email;
    resBody["password"] = password;
    resBody["name"] = name;
    resBody["office"] = office;
    resBody["userid"] = userid;

    final response = 
      await http.post("https://projetopds-72fa1.firebaseapp.com/api/v1/contacts", 
      headers: {"Content-Type": "application/json"},
      body: json.encode(resBody));

    // int statusCode = response.statusCode;
    // print(statusCode);
    // print(response.body);
  }

  addArchive(advogado, oab, autor, cep, cidade, comarca, contato, cpf, data, protocolo, uf, vara) async {
    try {
      var resBody = {};
      resBody["advogado"] = advogado;
      resBody["oab"] = oab;
      resBody["autor"] = autor;
      resBody["cep"] = cep;
      resBody["cidade"] = cidade;
      resBody["comarca"] = comarca;
      resBody["contato"] = contato;
      resBody["cpf"] = cpf;
      resBody["data"] = data;
      resBody["protocolo"] = protocolo;
      resBody["uf"] = uf;
      resBody["vara"] = vara;

      final response = 
        await http.post("https://projetopds-72fa1.firebaseapp.com/api/v1/processes", 
        headers: {"Content-Type": "application/json"},
        body: json.encode(resBody));
    } catch(e) {
      print(e);
      return false;
    }
    return true;
  }

  Future getProcess(User user) async {
    List<Processo> processes = List<Processo>();
    try{
      final response = await http.get(
        'https://projetopds-72fa1.firebaseapp.com/api/v1/processes'
      );
      
      Map<String, dynamic> jsonResponse = json.decode(response.body)['processos'];

      jsonResponse.forEach((key, value) {
        bool result = false;
        user.processes.forEach((element) {
          if(element == key.toString()) result = true;
        });
        if(result) {
          print(key);
          processes.add(Processo(
            advogado: value['advogado'],
            oab: value['oab'],
            autor: value['autor'],
            cep: value['cep'],
            cidade: value['cidade'],
            comarca: value['comarca'],
            contato: value['contato'],
            cpf: value['cpf'],
            data: value['data'],
            protocolo: value['protocolo'],
            uf: value['uf'],
            vara: value['vara'],
            archives: value['archives'],
            status: value['status']
          ));
        }
      });

      // print("\n\n\n");
      // print('\nPrint processes\n');
      // processes.forEach((element) {
      //   print(element.advogado);
      // });
    } catch(e) {
      print(e);
      return null;
    }
    return processes;
  }
}