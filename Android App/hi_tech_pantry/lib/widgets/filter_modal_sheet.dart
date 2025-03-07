import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_state.dart';

class FilterModalSheet extends StatefulWidget {
  const FilterModalSheet({
    super.key,
    required this.selectedCategories,
    required this.selectedExpiryDates,
    required this.selectedQuantities,
  });

  final Set<String> selectedCategories;
  final Set<int> selectedExpiryDates;
  final Set<int> selectedQuantities;

  @override
  State<FilterModalSheet> createState() => _FilterModalSheetState();
}

class _FilterModalSheetState extends State<FilterModalSheet> {
  late Set<String> selectedCategories;
  late Set<int> selectedExpiryDates;
  late Set<int> selectedQuantities;

  Set<String> availableExpiryDates = {'Expired', 'Expiring Soon (within 3 days)', 'Expires Later (more than 3 days)'};
  Set<String> availableQuantities = {'1 - 3', '4+'};

  @override
  void initState() {
    super.initState();
    selectedCategories = {...widget.selectedCategories};
    selectedExpiryDates = {...widget.selectedExpiryDates};
    selectedQuantities = {...widget.selectedQuantities};
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      height: 430,
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expiry Date', style: TextStyle(color: Colors.blue.shade700, fontSize: 18, fontWeight: FontWeight.w500)),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            child: Wrap(
              runSpacing: 5,
              spacing: 5,
              children: [
                for (int i = 0; i <= 2; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedExpiryDates.contains(i)) {
                          selectedExpiryDates.remove(i);
                        } else {
                          selectedExpiryDates.add(i);
                        }
                      });
                    },
                    child: Chip(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(availableExpiryDates.elementAt(i)),
                      backgroundColor: selectedExpiryDates.contains(i) ? Colors.blue.shade700 : isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selectedExpiryDates.contains(i) ? Colors.white : Colors.blue.shade700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.blue.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Visibility(
              visible: appState.productCategories.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category', style: TextStyle(color: Colors.blue.shade700, fontSize: 18, fontWeight: FontWeight.w500)),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: double.infinity,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(5),
                        physics: BouncingScrollPhysics(),
                        child: Wrap(
                          runSpacing: 5,
                          spacing: 5,
                          children: [
                            for (var category in appState.productCategories)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedCategories.contains(category)) {
                                      selectedCategories.remove(category);
                                    } else {
                                      selectedCategories.add(category);
                                    }
                                  });
                                },
                                child: Chip(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  label: Text(category),
                                  backgroundColor: selectedCategories.contains(category) ? Colors.blue.shade700 : isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: selectedCategories.contains(category) ? Colors.white : Colors.blue.shade700,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Colors.blue.shade700,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('Quantity', style: TextStyle(color: Colors.blue.shade700, fontSize: 18, fontWeight: FontWeight.w500)),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            child: Wrap(
              runSpacing: 5,
              spacing: 5,
              children: [
                for (int i = 0; i <= 1; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedQuantities.contains(i)) {
                          selectedQuantities.remove(i);
                        } else {
                          selectedQuantities.add(i);
                        }
                      });
                    },
                    child: Chip(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(availableQuantities.elementAt(i)),
                      backgroundColor: selectedQuantities.contains(i) ? Colors.blue.shade700 : isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selectedQuantities.contains(i) ? Colors.white : Colors.blue.shade700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.blue.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.pop([false, null, null, null]);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                  ),
                  child: Text('Clear', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.pop([true, selectedExpiryDates, selectedCategories, selectedQuantities]);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: isDarkMode ? Colors.grey[850] : Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Apply', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}