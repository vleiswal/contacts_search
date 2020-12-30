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
  List<Contact> contactsFiltered = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getAllContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  String flattenPhoneNumbers(String phoneNoString) {
    return phoneNoString.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == '+' ? '+' : '';
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);

    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchStringFlatten = flattenPhoneNumbers(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);

        if (nameMatches) {
          return true;
        }

        if (searchStringFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phoneNo) {
          String phoneNoFlattened = flattenPhoneNumbers(phoneNo.value);

          return phoneNoFlattened.contains(searchStringFlatten);
        }, orElse: () => null);
        return phone != null;
      });

      setState(() {
        contactsFiltered = _contacts;
      });
    }
  }

  getAllContacts() async {
    // Get all contacts on device
    // Get all contacts without thumbnail (faster)
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();

    setState(() {
      //print(_contacts.length);
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts App'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Name to search',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    isSearching ? contactsFiltered.length : contacts.length,
                itemBuilder: (context, index) {
                  Contact contact =
                      isSearching ? contactsFiltered[index] : contacts[index];

                  return ListTile(
                    title: Text(contact.displayName),
                    subtitle: Text(contact.phones.elementAt(0).value),
                    leading:
                        (contact.avatar != null && contact.avatar.length > 0)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.avatar),
                              )
                            : CircleAvatar(
                                radius: 15,
                                child: Text(
                                  contact.initials(),
                                ),
                              ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
