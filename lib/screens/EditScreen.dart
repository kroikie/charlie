import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/charlieutil.dart';

import '../models/company.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final deleteChoice = await showDialog<bool>(context: context, builder: (context) {
                return AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text('Are you sure you want to delete this company?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        GoRouter.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        GoRouter.of(context).pop(true);
                      },
                    ),
                  ],
                );
              });
              if (deleteChoice != null && deleteChoice) {
                if (!context.mounted) return;
                GoRouter.of(context).goNamed('home');
                FirebaseFirestore.instance.doc('companies/$companyId').delete();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: StreamBuilder(
          stream: companyStream,
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasData && streamSnapshot.data != null && streamSnapshot.data!.exists) {
              final wasteCompany = WasteCompany.fromJson(companyId, streamSnapshot.data!.data()!);
              return CompanyForm(company: wasteCompany);
            } else {
              return const Center(child: Text('loading...'));
            }
          },
        ),
      ),
    );
  }
}

class CompanyForm extends StatelessWidget {
  final WasteCompany? company;
  late final nameController = TextEditingController(text: company != null ? company!.name : '');
  late final typeController = TextEditingController(text: company != null ? company!.wasteTypes.map((wasteType) => wasteType.label).join(", ") : '');
  late final phoneController = TextEditingController(text: company != null ? company!.phone : '');
  late final addressController = TextEditingController(text: company != null ? company!.address : '');
  late final latController = TextEditingController(text: company != null ? company!.location.latitude.toString() : '');
  late final lngController = TextEditingController(text: company != null ? company!.location.longitude.toString() : '');

  CompanyForm({super.key, required this.company});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Company Name',
            ),
            validator: companyStringValidator,
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Waste Types',
                  ),
                  readOnly: true,
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final wasteChoice = await _buildWasteChoiceDialog(
                      context,
                      company == null ? [] : List.from(company!.wasteTypes)
                  );
                  if (wasteChoice != null) {
                    if (company != null) {
                      company!.wasteTypes = wasteChoice;
                    }
                    typeController.text = wasteChoice.map((wasteType) => wasteType.label).toList().join(', ');
                  }
                }
              ),
            ],
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Phone',
            ),
            validator: companyStringValidator,
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Address',
            ),
            validator: companyStringValidator,
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: latController,
            decoration: const InputDecoration(
              labelText: 'Latitude',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              return companyLatLngValidator('lat', value);
            },
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: lngController,
            decoration: const InputDecoration(
              labelText: 'Longitude',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              return companyLatLngValidator('lng', value);
            },
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedWastCompany = WasteCompany(
                      id: company != null ? company!.id : 'default_id',
                      name: nameController.text,
                      address: addressController.text,
                      wasteTypes: company != null ?
                          company!.wasteTypes :
                          typeController.text.split(', ').map((str) {
                            return WasteType.fromLabel(str);
                          }).toList(),
                      phone: phoneController.text,
                      location: GeoPoint(
                        double.parse(latController.text),
                        double.parse(lngController.text),
                      ),
                  );
                  if (company != null) {
                    // update company
                    FirebaseFirestore.instance.doc('companies/${company!.id}')
                        .set(updatedWastCompany.toJson());
                  } else {
                    // add company
                    final ref = await FirebaseFirestore.instance.collection('companies')
                        .add(updatedWastCompany.toJson());
                    if (!context.mounted) return;
                    GoRouter.of(context).pushReplacementNamed('detail', pathParameters: {'companyId': ref.id});
                  }
                }
              },
              child: const Text('SAVE')),
        ],
      )
    );
  }

  Future<List<WasteType>?> _buildWasteChoiceDialog(BuildContext context, List<WasteType> wasteChoices) {
    return showDialog<List<WasteType>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Company Waste'),
          content: SizedBox(
            width: double.maxFinite,
            child: WasteFilterList(wasteTypeSelections: wasteChoices),
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
                Navigator.of(context).pop(wasteChoices);
              },
            ),
          ],
        );
      }
    );
  }

  String? companyStringValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? companyLatLngValidator(String latOrLng, String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    } else if (double.tryParse(value) == null) {
      return 'This field must be a valid number';
    } else {
      final doubleValue = double.parse(value);
      if (latOrLng == 'lat' && doubleValue < -90 && doubleValue > 90) {
        return 'Latitude must be between -90 and 90';
      } else if (latOrLng == 'lng' && doubleValue < -180 && doubleValue > 180) {
        return 'Longitude must be between -180 and 180';
      }
    }
    return null;
  }
}
