// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:tichu/screens/team_selection.dart';
import 'package:tichu/screens/tichu_table.dart';
import 'package:tichu/models/sign-up-model.dart';
import 'package:tichu/widget/login_fresh_reset_password.dart';
import 'package:tichu/screens/login_by_username_and_password.dart';
import 'package:tichu/widget/register_as_new_user.dart';

import 'common/theme.dart';
import 'game-utils.dart';
import 'models/register-player-model.dart';

void main() {
  runApp(const TichuApp());
}

class TichuApp extends StatelessWidget {
  const TichuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using MultiProvider is convenient when providing multiple objects.
    return MultiProvider(
      providers: [
        // In this sample app, TeamModel never changes, so a simple Provider
        // is sufficient.
        Provider(create: (context) => RegisterPlayerModel()),
        // PlayerModel is implemented as a ChangeNotifier, which calls for the use
        // of ChangeNotifierProvider. Moreover, PlayerModel depends
        // on TeamModel, so a ProxyProvider is needed.
        ChangeNotifierProvider<RegisterPlayerModel>(
          create: (context) => RegisterPlayerModel()
        ),
      ],
      child: MaterialApp(
          title: 'TichuGame',
          theme: appTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => buildLoginByUsernameAndPassword(context),
            '/signup': (context) => buildRegisterAsNewUser(),
            '/resetPassword': (context) => TeamSelection(), // TODO
            '/team': (context) => TeamSelection(),
            '/play': (context) =>
            context.read<RegisterPlayerModel>().isValidToken()
                ? TichuTable(player: context.read<RegisterPlayerModel>())
                : buildLoginByUsernameAndPassword(context),
          }
      ),
    );
  }

  LoginByUsernameAndPassword buildLoginByUsernameAndPassword(BuildContext context) {
    return LoginByUsernameAndPassword(
      callLogin: (BuildContext _context, Function isRequest,
          String user, String password, String serverIp) async {
        isRequest(true);
        RegisterPlayerModel player = context.read<RegisterPlayerModel>();
        player.name = user;
        player.serverIp = serverIp;
        //final ioc = new HttpClient();
        //ioc.badCertificateCallback =
        //    (X509Certificate cert, String host, int port) => true;
        // final http1 = new IOClient(ioc);
        final http1 = new IOClient();

        final response = await http1.post(
          Uri.http("${player.serverIp}:${GameUtils.PORT}", "/login"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            GameUtils.USERNAME_KEY: user,
            'password': password,
          }),
        );
        isRequest(false);
        print("Response status : ${response.statusCode}");
        if (response.statusCode == 200) {
          player.setToken(jsonDecode(response.body)["token"]);
          Navigator.pushNamed(context, '/team');
        } else {
          // If the server did not return a 200 OK response,
          // then send back to login
          Navigator.pushNamed(context, '/');
        }
      },
      enableResetPassword: true,
      enableSignUp: true,
    );
  }


  Widget widgetResetPassword() {
    return LoginFreshResetPassword(
      logo: './assets/images/cards/15.png',
      funResetPassword:
          (BuildContext _context, Function isRequest, String email) {
        isRequest(true);

        Future.delayed(Duration(seconds: 2), () {
          print('-------------- function call----------------');
          print(email);
          print('--------------   end call   ----------------');
          isRequest(false);
        });
      },
    );
  }

  RegisterAsNewUser buildRegisterAsNewUser() {
    return RegisterAsNewUser(
        logo: 'assets/images/logo_head.png',
        funSignUp: (BuildContext _context, Function isRequest,
            SignUpModel signUpModel) async {
          isRequest(true);

          print(signUpModel.email);
          //TODO - check password, compare passwords
          print(signUpModel.password);
          print(signUpModel.repeatPassword);
          print(signUpModel.surname);
          // TODO - check name not empty
          print(signUpModel.name);

          final ioc = new HttpClient();
          ioc.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          final http1 = new IOClient(ioc);

          final response = await http1.post(
            // Uri.https("192.168.2.114", "/auth/register"),
            Uri.http("10.0.2.2:5000", "/auth/register"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              GameUtils.USERNAME_KEY: signUpModel.name ?? '',
              'password': signUpModel.password ?? '',
            }),
          );

          isRequest(false);

          print("Response status : ${response.statusCode}");
          //TODO - the server should probably return another response code
          if (response.statusCode == 302) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            print("Response body : ${response.body}");
            var myresponse = jsonDecode(response.body);
            //return PlayerModel.fromJson(jsonDecode(response.body));
          } else {
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception('Failed to register new user.');
          }

        });
  }

}
