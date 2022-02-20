import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tichu/game-utils.dart';
import 'package:tichu/models/register-player-model.dart';

import '../config/language.dart';
import '../widget/login_fresh_loading.dart';

/// This was inspired and is loosely based on https://pub.dev/packages/login_fresh
///
class LoginByUsernameAndPassword extends StatefulWidget {
  final Color backgroundColor = GameUtils.BACKGROUND_COLOR;
  final String logoLeft = './assets/images/cards/15.png';
  final String logoRight = './assets/images/cards/0.png';
  final Color textColor = const Color(0xFF0F2E48);

  final bool enableResetPassword;

  final bool enableSignUp;

  final Function callLogin;

  final LanguageTranslate uiStrings = LanguageTranslate();

  LoginByUsernameAndPassword(
      {Key? key, required this.callLogin,
      required this.enableResetPassword,
      required this.enableSignUp}) : super(key: key);

  @override
  _LoginByUsernameAndPasswordState createState() =>
      _LoginByUsernameAndPasswordState();
}

class _LoginByUsernameAndPasswordState
    extends State<LoginByUsernameAndPassword> {
  final TextEditingController _textEditingControllerPassword =
      TextEditingController();
  final TextEditingController _textEditingControllerUser =
      TextEditingController();
  final TextEditingController _textEditingControllerServer =
      TextEditingController();

  bool _isPasswordHidden = true;

  bool isRequest = false;

  final focus = FocusNode();

  final bool isLoginRequest = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: widget.backgroundColor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            widget.uiStrings.login,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const  TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          )),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              color: widget.backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Hero(
                        tag: 'hero-login-logo-left',
                        child: Image.asset(
                          widget.logoLeft,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Hero(
                        tag: 'hero-login-logo-right',
                        child: Image.asset(
                          widget.logoRight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Color(0xFFF3F3F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  )),
              child: buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        const SizedBox(
          height: 0,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                Consumer<RegisterPlayerModel>(
                    builder: (context, player, child) {
                  if (_textEditingControllerUser.text.isEmpty) {
                    _textEditingControllerUser.text = player.name;
                  }
                  return buildUsernameInputField(context,
                      _textEditingControllerUser, TextInputType.emailAddress);
                }),
                buildPasswordInputField(),
                Consumer<RegisterPlayerModel>(
                    builder: (context, player, child) {
                  if (_textEditingControllerServer.text.isEmpty) {
                    _textEditingControllerServer.text = player.serverIp;
                  }
                  return buildUsernameInputField(
                      context, _textEditingControllerServer, TextInputType.url);
                }),
                (isRequest)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LoadingLoginFresh(
                          textLoading: widget.uiStrings.textLoading,
                          colorText: widget.textColor,
                          backgroundColor: widget.backgroundColor,
                          elevation: 0,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          widget.callLogin(
                              context,
                              setIsRequest,
                              _textEditingControllerUser.text,
                              _textEditingControllerPassword.text,
                              _textEditingControllerServer.text);
                        },
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                color: widget.backgroundColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Center(
                                      child: Text(
                                    widget.uiStrings.login,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  )),
                                ))),
                      ),
                (widget.enableResetPassword)
                    ? GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 25, left: 10, right: 10),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: '',
                                  style: TextStyle(
                                      color: widget.textColor,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15)),
                              TextSpan(
                                  text: widget.uiStrings.recoverPassword,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: widget.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ]),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/resetPassword');
                        },
                      )
                    : const SizedBox(),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: widget.uiStrings.notAccount + ' \n',
                            style: TextStyle(
                                color: widget.textColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 15)),
                        TextSpan(
                            text: widget.uiStrings.signUp,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: widget.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ]),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
              ],
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(),
        ),
      ],
    );
  }

  Padding buildPasswordInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: TextField(
          focusNode: focus,
          controller: _textEditingControllerPassword,
          obscureText: _isPasswordHidden,
          style: TextStyle(color: widget.textColor, fontSize: 14),
          onSubmitted: (value) {
            widget.callLogin(
                context,
                setIsRequest,
                _textEditingControllerUser.text,
                _textEditingControllerPassword.text,
                _textEditingControllerServer);
          },
          decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images_login_fresh_34_/icon_password.png",
                  width: 15,
                  height: 15,
                ),
              ),
              suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                  child: (_isPasswordHidden)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images_login_fresh_34_/icon_eye_close.png",
                            width: 15,
                            height: 15,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images_login_fresh_34_/icon_eye_open.png",
                            width: 15,
                            height: 15,
                          ),
                        )),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFAAB5C3))),
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              focusColor: const Color(0xFFF3F3F5),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFAAB5C3))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: widget.backgroundColor)),
              hintText: widget.uiStrings.hintLoginPassword)),
    );
  }

  Padding buildUsernameInputField(BuildContext context, controller, inputType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
          controller: controller,
          keyboardType: inputType,
          style: TextStyle(color: widget.textColor, fontSize: 14),
          autofocus: true,
          onSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus);
          },
          decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images_login_fresh_34_/icon_user.png",
                  width: 15,
                  height: 15,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFAAB5C3))),
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              focusColor: const Color(0xFFF3F3F5),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFAAB5C3))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: widget.backgroundColor)),
              hintText: widget.uiStrings.hintLoginUser)),
    );
  }

  void setIsRequest(bool isRequest) {
    setState(() {
      this.isRequest = isRequest;
    });
  }
}
