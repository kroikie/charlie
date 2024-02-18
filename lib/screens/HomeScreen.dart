import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => GoRouter.of(context).push('/login'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _buildFilterDialog(context),
          )
        ],
      ),
      body: Center(
        child: Consumer<List<WasteCompany>>(
          builder: (_, companies, __) {
            return ListView.builder(
              itemCount: companies.length,
              itemBuilder: (BuildContext context, int index) {
                return CompanyItem(company: companies[index]);
              },
            );
          },
        ),
      ),
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
              child: Icon(getWasteIcon(company.type)),
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

  IconData getWasteIcon(String wasteType) {
    switch(wasteType) {
      case "Bulky Waste":
        return Icons.local_shipping;
      case "E Waste":
        return Icons.electric_bolt;
      case "Batteries":
        return Icons.battery_charging_full;
      case "Used Cooking Oil":
        return Icons.soup_kitchen;
      case "Beverage Containers":
        return Icons.local_drink;
      case "Organic Waste":
        return Icons.grass;
      case "Paper Waste":
        return Icons.feed;
      case "Car Oil":
        return Icons.local_gas_station;
      case "Flourescent Bulbs/Tubes":
        return Icons.light_mode;
      default:
        return Icons.recycling;
    }
  }
}

Future<void> _buildFilterDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(

        title: const Text('Filter Recycling Types'),
        content: Column(
          children: [
            ListTile(
              title: const Text('Bulky Waste'),
              leading: Radio<String>(
                value: 'Bulky Waste',
                groupValue: '',
                onChanged: (String? str) {
                },
              ),
            ),
          ],
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
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  );
}