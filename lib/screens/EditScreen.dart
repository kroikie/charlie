import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/company.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({
    super.key,
    required this.company,
  });

  final WasteCompany company;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company.name),
        leading: BackButton(
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Center(child: Text(company.name),),
    );
  }
}
