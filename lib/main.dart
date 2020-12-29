import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getAllContacts();
  }

  getAllContacts() async {
    // Get all contacts on device
    // Get all contacts without thumbnail (faster)
    List<Contact> _contacts =
        (await ContactsService.getContacts(withThumbnails: false)).toList();

    setState(() {
      //print(_contacts.length);
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts App'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact contact = contacts[index];

                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: Text(contact.phones.elementAt(0).value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
