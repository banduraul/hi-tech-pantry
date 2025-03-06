import 'package:flutter/material.dart';

class CategoriesContainer extends StatelessWidget {
  const CategoriesContainer({
    super.key,
    required this.categories,
    required this.selected,
    required this.isDarkMode,
    required this.onSelected
  });

  final List<String> categories;
  final Set<String> selected;
  final bool isDarkMode;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    categories.sort();
    return Container(
      margin: const EdgeInsets.only(top: 5),
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
              for (var category in categories)
                GestureDetector(
                  onTap: () {
                    onSelected(category);
                  },
                  child: Chip(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(category),
                    backgroundColor: selected.contains(category) ? Colors.blue.shade700 : isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: selected.contains(category) ? Colors.white : Colors.blue.shade700,
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
    );
  }
}