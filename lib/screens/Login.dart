import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum FormType { LOGIN, REGISTER }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _email, _password, _firstName, _lastName;
  String _pageTitle = "Account Login";
  FormType _formType = FormType.LOGIN;

  bool validate() {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  _showErrorMessage(_error) {
    // if one is open, close it
    _scaffoldKey.currentState
        .hideCurrentSnackBar(reason: SnackBarClosedReason.action);

    SnackBar snackBar = SnackBar(
      content: Text(_error.message),
      duration: Duration(seconds: 30),
      backgroundColor: Colors.redAccent,
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          // Some code to undo the change!
          _scaffoldKey.currentState
              .hideCurrentSnackBar(reason: SnackBarClosedReason.action);
        },
      ),
    );

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    _scaffoldKey.currentState.showSnackBar(snackBar).closed.then((reason) {
      // snackbar is now closed, close window
    });
  }

  void submit() async {
    if (validate()) {
      try {
        //final auth = Provider.of(context).auth;
        if (_formType == FormType.LOGIN) {
          FirebaseUser user =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          print('Signed in ${user.uid}');
        } else {
          FirebaseUser user = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password);

          print('Registered ${user.uid}');
        }
      } catch (e) {
        print(e);
        _showErrorMessage(e);
      }
    }
  }

  void switchFormState(String state) {
    formKey.currentState.reset();

    if (state == 'register') {
      setState(() {
        _formType = FormType.REGISTER;
        _pageTitle = 'Account Registration';
      });
    } else {
      setState(() {
        _formType = FormType.LOGIN;
        _pageTitle = 'Account Login';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_pageTitle),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: buildInputs(_formType) +
                  [
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                        child: Column(children: buildButtons()))
                  ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs(FormType formType) {
    var base = <Widget>[
      TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        onSaved: (value) => _email = value,
      ),
      TextFormField(
        //validator: PasswordValidator.validate,
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        onSaved: (value) => _password = value,
      ),
    ];

    if (formType == FormType.REGISTER) {
      return base +
          <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'First Name'),
              onSaved: (value) => _firstName = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'LastName'),
              onSaved: (value) => _lastName = value,
            )
          ];
    } else {
      return base;
    }
  }

  List<Widget> buildButtons() {
    if (_formType == FormType.LOGIN) {
      return [
        RaisedButton(
          child: Align(alignment: Alignment.center, child: Text('Login')),
          onPressed: submit,
        ),
        RaisedButton(
          child: Align(
              alignment: Alignment.center, child: Text('Register Account')),
          onPressed: () {
            switchFormState('register');
          },
        ),
      ];
    } else {
      return [
        RaisedButton(
          child:
              Align(alignment: Alignment.center, child: Text('Create Account')),
          onPressed: submit,
        ),
        RaisedButton(
          child: Align(alignment: Alignment.center, child: Text('Go to Login')),
          onPressed: () {
            switchFormState('login');
          },
        )
      ];
    }
  }
}
