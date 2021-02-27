import 'package:cryptocoin/Configuration/config.dart';
import 'package:cryptocoin/Configuration/customColor.dart';
import 'package:cryptocoin/Screen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
          accentColor: Color(0xFF162D3B), primarySwatch: MyColor.navy),
      theme: ThemeData(
          accentColor: Color(0xFF162D3B), primarySwatch: MyColor.navy),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final LocalAuthentication auth = LocalAuthentication();

  authenticate() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (canCheckBiometrics) {
      bool didAuthenticate = await auth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to Proceed',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      if (didAuthenticate) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      } else
        authenticate();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        authenticate();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(Theme.of(context).brightness);
    return Scaffold(
      body: Scaffold(
        backgroundColor: Config().baseColor,
      ),
    );
  }
}
