import 'dart:convert';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aad/config.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  bool _login;
  String _displayName;
  AadOAuth _oauth;
  String _accessToken;

  @override
  void initState() {
    _login = false;
    _displayName = 'Guest';

    final Config config = new Config(Configurations.aadTanentId,
        Configurations.aadClientId, "openid profile offline_access user.read");

    _oauth = AadOAuth(config);

    super.initState();
  }

  Widget _userImage() {
    if (!_login) {
      return Icon(
        Icons.account_circle,
        size: 180.0,
        color: Colors.grey,
      );
    } else {
      final String url = '${Configurations.aadApiUrl}/me/photo/\$value';
      final Map<String, String> headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json'
      };

      return Image.network(
        url,
        headers: headers,
        height: 180.0,
      );
    }
  }

  Widget _loginButtons() {
    if (!_login) {
      return OutlineButton(
        child: Text('Login using UP Account'),
        onPressed: () {
          _oauth.login().then((_) {
            _oauth.getAccessToken().then((accessToken) {
              _accessToken = accessToken;

              final String url = '${Configurations.aadApiUrl}/me';
              final Map<String, String> headers = {
                'Authorization': 'Bearer $_accessToken',
                'Content-Type': 'application/json'
              };

              http.get(url, headers: headers).then((response) {
                print(response.body);

                final Map<String, dynamic> userProfile =
                    json.decode(response.body);

                print(userProfile);

                setState(() {
                  _login = true;
                  _displayName = userProfile['displayName'];
                });
              });
            });
          });
        },
      );
    } else {
      return OutlineButton(
        child: Text('Logout'),
        onPressed: () {
          _oauth.logout().then((_) {
            setState(() {
              _displayName = 'Guest';
              _login = false;
            });
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Azure AD')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userImage(),
            SizedBox(
              height: 10.0,
            ),
            Text(
              _displayName,
              style: TextStyle(fontSize: 22.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            _loginButtons(),
          ],
        ),
      ),
    );
  }
}
