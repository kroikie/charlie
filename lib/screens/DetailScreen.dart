import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/charlieutil.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/company.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.companyId,
  });

  final String companyId;

  @override
  Widget build(BuildContext context) {
    final companyStream = FirebaseFirestore.instance.doc('companies/$companyId').snapshots();
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: companyStream,
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasData && streamSnapshot.data != null && streamSnapshot.data!.exists) {
              return Text(streamSnapshot.data!.get('name'));
            } else {
              return const Text('loading...');
            }
          },
        ),
        leading: BackButton(
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData && streamSnapshot.data != null) {
                return FutureBuilder(
                  future: CharlieUtil.isAdmin(),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.hasData && futureSnapshot.data == true) {
                      return IconButton(
                        onPressed: () {
                          GoRouter.of(context).pushNamed('edit_company', pathParameters: {'companyId': companyId});
                        },
                        icon: const Icon(Icons.edit),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return const SizedBox.shrink();
            }
          ),
        ],
      ),
      body: StreamBuilder(
        stream: companyStream,
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasData && streamSnapshot.data != null && streamSnapshot.data!.exists) {
            final company = WasteCompany.fromJson(companyId, streamSnapshot.data!.data()!);
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(company.name)),
                  ListTile(
                      leading: const Icon(Icons.recycling),
                      title: Text(company.type)),
                  ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(company.phone)),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(company.address),
                    onTap: () async {
                      var urlStr = "https://www.google.com/maps/dir/?api=1&q=${company
                          .location.latitude},${company.location.longitude}";
                      if (Theme
                          .of(context)
                          .platform == TargetPlatform.iOS) {
                        urlStr = "http://maps.apple.com/?ll=${company
                            .location.latitude},${company.location.longitude}";
                      }
                      if (await canLaunchUrlString(urlStr)) {
                        launchUrlString(urlStr);
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('loading...'));
          }
        }
      ),
    );
  }
}
