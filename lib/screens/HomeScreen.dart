import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../charlieutil.dart';
import '../models/company.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var companyQuery = WasteCompanyModel.generateQuery(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('De Right Place'),
        actions: [
          StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, streamSnapsoht) {
                if (streamSnapsoht.hasData && streamSnapsoht.data != null) {
                  return IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => GoRouter.of(context).push('/login'),
                );
              }
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final storedFilter = prefs.getStringList('wasteTypeFilter');
              if (!context.mounted) return;
              final filterChoice = await _buildFilterDialog(
                  context,
                  storedFilter != null ?
                    storedFilter.map((wasteTypeName) => WasteType.fromName(wasteTypeName)).toList() :
                    []
              );
              setState(() {
                if (filterChoice != null && filterChoice.isNotEmpty) {
                  companyQuery = WasteCompanyModel.generateQuery(filterChoice);
                  prefs.setStringList('wasteTypeFilter', filterChoice.map((wasteType) => wasteType.name).toList());
                } else {
                  companyQuery = WasteCompanyModel.generateQuery(null);
                  prefs.remove('wasteTypeFilter');
                }
              });
            },
          )
        ],
      ),
      body: StreamBuilder<List<WasteCompany>>(
        stream: companyQuery
            .withConverter(
              fromFirestore: (snapshot, _) => WasteCompany.fromJson(snapshot.id, snapshot.data()!),
              toFirestore: (company, _) => company.toJson()
            )
            .snapshots().map((event) => event.docs.map((ele) => ele.data()).toList()),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasData && streamSnapshot.data != null) {
            return Center(
              child: ListView.builder(
                itemCount: streamSnapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return CompanyItem(company: streamSnapshot.data![index]);
                },
              ),
            );
          } else {
            return const Center(
              child: Text('loading...'),
            );
          }
        }
      ),
      floatingActionButton: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder(
                future: CharlieUtil.isAdmin(),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.hasData && futureSnapshot.data == true) {
                    return FloatingActionButton(
                      onPressed: () => GoRouter.of(context).pushNamed('add_company'),
                      child: const Icon(Icons.add),
                    );
                  }
                  return const SizedBox.shrink();
                }
            );
          }
          return const SizedBox.shrink();
        },
      )
    );
  }
}

class CompanyItem extends StatelessWidget {
  const CompanyItem({super.key, required this.company});
  
  final WasteCompany company;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).go('/details/${company.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: company.wasteTypes.length > 1 ?
                  const Icon(Icons.recycling) :
                  Icon(CharlieUtil.getWasteIcon(company.wasteTypes[0])),
            ),
            Flexible(
              child: Text(
                company.name,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<WasteType>?> _buildFilterDialog(BuildContext context, List<WasteType> recyclingFilter) async {

  return showDialog<List<WasteType>?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(

        title: const Text('Filter Waste Types'),
        content: SizedBox(
            width: double.maxFinite,
            child: WasteFilterList(wasteTypeSelections: recyclingFilter,)
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Apply'),
            onPressed: () {
              Navigator.of(context).pop(recyclingFilter);
            },
          ),
        ],
      );
    }
  );
}
