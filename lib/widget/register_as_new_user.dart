import 'package:flutter/material.dart';
import 'login_fresh_loading.dart';
import '../config/language.dart';
import '../models/sign-up-model.dart';

class RegisterAsNewUser extends StatefulWidget {
  final Color backgroundColor = Color(0xFFE7004C);

  final Color textColor = Color(0xFF0F2E48);

  final LanguageTranslate loginFreshWords = LanguageTranslate();

  final Function funSignUp;

  final String logo;

  RegisterAsNewUser(
      {required this.funSignUp,
      required this.logo});

  @override
  _RegisterAsNewUserState createState() => _RegisterAsNewUserState();
}

class _RegisterAsNewUserState extends State<RegisterAsNewUser> {
  SignUpModel signUpModel = SignUpModel();

  bool isRequest = false;

  bool isNoVisiblePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: widget.backgroundColor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            widget.loginFreshWords.signUp,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
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
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 3),
                        child: Hero(
                          tag: 'hero-login',
                          child: Image.asset(
                            widget.logo,
                            fit: BoxFit.contain,
                          ),
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
              decoration: new BoxDecoration(
                  color: Color(0xFFF3F3F5),
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(50.0),
                    topRight: const Radius.circular(50.0),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 5, left: 20, right: 20, top: 20),
                    child: TextField(
                        onChanged: (String value) {
                          this.signUpModel.email = value;
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            color: widget.textColor,
                            fontSize: 14),
                        autofocus: false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            filled: true,
                            fillColor: Color(0xFFF3F3F5),
                            focusColor: Color(0xFFF3F3F5),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: widget.backgroundColor)),
                            hintText: widget.loginFreshWords.hintLoginUser)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextField(
                        onChanged: (String value) {
                          this.signUpModel.name = value;
                        },
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            color: widget.textColor ,
                            fontSize: 14),
                        autofocus: false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            filled: true,
                            fillColor: Color(0xFFF3F3F5),
                            focusColor: Color(0xFFF3F3F5),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: widget.backgroundColor)),
                            hintText: widget.loginFreshWords.hintName)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextField(
                        onChanged: (String value) {
                          this.signUpModel.surname = value;
                        },
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            color: widget.textColor,
                            fontSize: 14),
                        autofocus: false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            filled: true,
                            fillColor: Color(0xFFF3F3F5),
                            focusColor: Color(0xFFF3F3F5),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: widget.backgroundColor)),
                            hintText: widget.loginFreshWords.hintSurname)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: TextField(
                        onChanged: (String value) {
                          this.signUpModel.password = value;
                        },
                        obscureText: this.isNoVisiblePassword,
                        style: TextStyle(
                            color: widget.textColor,
                            fontSize: 14),
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (this.isNoVisiblePassword)
                                      this.isNoVisiblePassword = false;
                                    else
                                      this.isNoVisiblePassword = true;
                                  });
                                },
                                child: (this.isNoVisiblePassword)
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
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            filled: true,
                            fillColor: Color(0xFFF3F3F5),
                            focusColor: Color(0xFFF3F3F5),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: widget.backgroundColor)),
                            hintText: widget.loginFreshWords.hintLoginPassword)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: TextField(
                        onChanged: (String value) {
                          this.signUpModel.repeatPassword = value;
                        },
                        obscureText: this.isNoVisiblePassword,
                        style: TextStyle(
                            color: widget.textColor ,
                            fontSize: 14),
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            filled: true,
                            fillColor: Color(0xFFF3F3F5),
                            focusColor: Color(0xFFF3F3F5),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Color(0xFFAAB5C3))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: widget.backgroundColor)),
                            hintText:
                            widget.loginFreshWords.hintSignUpRepeatPassword)),
                  )
                ],
              ),
            ),
          ),
          (this.isRequest)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LoadingLoginFresh(
                    textLoading: widget.loginFreshWords.textLoading,
                    colorText: widget.textColor,
                    backgroundColor: widget.backgroundColor,
                    elevation: 0,
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    widget.funSignUp(
                        context, this.setIsRequest, this.signUpModel);
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                                child: Text(
                                  widget.loginFreshWords.signUp,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )),
                          ))),
                ),
          SizedBox()
        ]);
  }

  void setIsRequest(bool isRequest) {
    setState(() {
      this.isRequest = isRequest;
    });
  }
}
