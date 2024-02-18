import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charlie'),
        leading: BackButton(
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Consumer<List<WasteCompany>>(
        builder: (_, companies, __) {
          final company = companies.firstWhere((element) => element.id == companyId);
          return Center(child: Text(company.name),);
        },
      ),
    );
  }
}
