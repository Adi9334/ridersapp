import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class Findcontacts extends StatefulWidget {
  const Findcontacts({super.key});

  @override
  State<Findcontacts> createState() => _FindcontactsState();
}

class _FindcontactsState extends State<Findcontacts> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndFetchContacts();
  }

  Future<void> _checkPermissionAndFetchContacts() async {
    // Request permission to read contacts
    bool permissionGranted = await FlutterContacts.requestPermission(readonly: true);
    if (!permissionGranted) {
      setState(() {
        _permissionDenied = true;
      });
      return;
    }

    // Fetch contacts
    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);

      setState(() {
        _contacts = contacts;
        _permissionDenied = false;
      });
    } catch (e) {
      print('Error fetching contacts: $e');
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'My Contacts',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _permissionDenied
          ? Center(
              child: Text(
                'Permission denied',
                style: GoogleFonts.nunito(fontSize: 18),
              ),
            )
          : _contacts == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _contacts!.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts![index];
                    final name = contact.displayName ?? 'No name';
                    final phones = contact.phones.isNotEmpty
                        ? contact.phones.map((phone) => phone.number).join(', ')
                        : 'No phone number';

                    return ListTile(
                      leading: const Icon(Icons.contact_phone, color: Colors.blue), // Icon before the name
                      title: Text(
                        name,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        phones,
                        style: GoogleFonts.nunito(fontSize: 14),
                      ),
                      onTap: () async {
                        final fullContact = await FlutterContacts.getContact(contact.id);
                        print(contact.id);
                        if (fullContact != null) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ContactPage(fullContact),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  ContactPage(this.contact);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          contact.displayName ?? 'Contact Details',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First name: ${contact.name.first ?? '(none)'}',
              style: GoogleFonts.nunito(fontSize: 18),
            ),
            Text(
              'Last name: ${contact.name.last ?? '(none)'}',
              style: GoogleFonts.nunito(fontSize: 18),
            ),
            Text(
              'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}',
              style: GoogleFonts.nunito(fontSize: 18),
            ),
            Text(
              'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}',
              style: GoogleFonts.nunito(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
