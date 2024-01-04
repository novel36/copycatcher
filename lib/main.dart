// import 'package:copycatcher/providers/history_provider.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:copycatcher/constant/app_constants.dart';
import 'package:copycatcher/models/clipboard_box.dart';
import 'package:copycatcher/providers/autosync_provider.dart';
import 'package:copycatcher/providers/clipboard_history_provider.dart';
import 'package:copycatcher/providers/sync_now_provider.dart';
import 'package:copycatcher/ui/clipboard_sync_page.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;

  await Hive.initFlutter();
  Hive.registerAdapter(ClipboardItemAdapter());
  Hive.registerAdapter(ClipBoardItemTypesAdapter());
  // await Hive.deleteBoxFromDisk('clipboarditems');
  Client client = Client();
  client = Client()
      .setEndpoint(Appconstants.endpoint)
      .setProject(Appconstants.projectID);

  Account account = Account(client);
  runApp(MyApp(
    account: account,
  ));
}

class MyApp extends StatelessWidget {
  final Account account;
  const MyApp({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return AppwriteAuthKit(
      client: account.client,
      child: MaterialApp(
          title: 'Flutter Demo',
          color: Colors.red,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              appBarTheme: const AppBarTheme(color: Colors.redAccent),
              colorScheme: const ColorScheme(
                  brightness: Brightness.light,
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  secondary: Colors.blue,
                  onSecondary: Colors.red,
                  error: Colors.red,
                  onError: Colors.redAccent,
                  background: Colors.red,
                  onBackground: Colors.red,
                  surface: Colors.red,
                  onSurface: Colors.red)),
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AutoSyncProvider>(
                create: (context) => AutoSyncProvider(),
              ),
              ChangeNotifierProvider<ClipboardHistoryProvider>(
                create: (context) => ClipboardHistoryProvider(),
              ),
              ChangeNotifierProvider<SyncNowProvider>(
                create: (context) => SyncNowProvider(),
              ),
            ],
            // builder: (context, child) => const ClipboardSyncPage(),
            builder: (context, child) => const MainScreen(),
          )),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.authNotifier;

    Widget widget;
    switch (authNotifier.status) {
      case AuthStatus.authenticated:
        // widget = MyCounterScreen(
        //   authNotifier: authNotifier,
        //   client: authNotifier.client,
        // );
        widget = ClipboardSyncPage(
          authNotifier: authNotifier,
        );
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        widget = LoginPage(
          client: authNotifier.client,
        );
        break;
      case AuthStatus.uninitialized:
      default:
        widget = const LoadingPage();
        break;
    }
    return widget;
  }
}

class AdminPage extends StatefulWidget {
  // final models.User? loggedInUser;

  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    final user = context.authNotifier.user;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "User ${user?.name} is Logged In",
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: () async {
                  await context.authNotifier.deleteSessions();
                },
                child: const Text("Log out"))
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Client client;
  const LoginPage({super.key, required this.client});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailFieldController;
  late TextEditingController _passwordFieldController;
  late final Databases databases;

  @override
  void initState() {
    databases = Databases(widget.client);
    _emailFieldController = TextEditingController();
    _passwordFieldController = TextEditingController();
    print("hello");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _emailFieldController,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _passwordFieldController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailFieldController.text;
                  final password = _passwordFieldController.text;
                  print("sessions");
                  await context.authNotifier
                      .createEmailSession(email: email, password: password)
                      .then((value) => print("Successful $value"));
                },
                child: const Text('Login'),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final email = _emailFieldController.text;
                    final password = _passwordFieldController.text;
                    await context.authNotifier
                        .create(email: email.trim(), password: password.trim())
                        .then((value) {
                      print('${value!.status}');
                      if (value.status) {
                        context.authNotifier.updateVerification(
                            userId: value.$id, secret: '$value.id');
                        // databases.createDocument(
                        //     databaseId: Appconstants.databaseID,
                        //     collectionId: Appconstants.countCollectionID,
                        //     documentId: 'count${value.$id}',
                        //     data: {'count': 0});
                      }
                    });
                  },
                  child: const Text("SignUp"))
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [CircularProgressIndicator.adaptive(), Text("Loading ...")],
        ),
      ),
    );
  }
}
