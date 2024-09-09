import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

class RecipeExpandableTile extends StatefulWidget {
  final String mealType;
  final List<RecipeStub> recipes;
  final Function(List<RecipeStub> recipes) onChanged;

  const RecipeExpandableTile({
    super.key,
    required this.mealType,
    required this.recipes,
    required this.onChanged,
  });

  @override
  _RecipeExpandableTileState createState() => _RecipeExpandableTileState();
}

class _RecipeExpandableTileState extends State<RecipeExpandableTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _chevronRotation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _chevronRotation = Tween(begin: 0.0, end: 0.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  int _getSelectedCount() {
    return widget.recipes.where((recipe) => recipe.isSelected).length;
  }

  bool _areAllSelected() {
    return widget.recipes.every((recipe) => recipe.isSelected);
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      for (var recipe in widget.recipes) {
        recipe.isSelected = value ?? false;
      }
    });
    widget.onChanged(widget.recipes
        .where((recipe) => recipe.isSelected)
        .toList()); // Trigger onChanged when all selected/deselected
  }

  void _toggleIndividualRecipe(RecipeStub recipe, bool? value) {
    setState(() {
      recipe.isSelected = value ?? false;
    });
    widget.onChanged(widget.recipes
        .where((recipe) => recipe.isSelected)
        .toList()); // Trigger onChanged when individual recipe changes
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.mealType,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600), // Bold meal type
                ),
              ),
              if (_getSelectedCount() > 0)
                Text(
                  '(${_getSelectedCount()} selected)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600], // Make the text smaller and grey
                  ),
                ),
            ],
          ),
          trailing: RotationTransition(
            turns: _chevronRotation,
            child: Icon(Icons.expand_more,
                color: Colors.grey[700]), // Chevron with gray color
          ),
          onTap: _toggleExpansion,
        ),
        SizeTransition(
          sizeFactor: _sizeAnimation, // Animate the size change
          child: Column(
            children: [
              // "Select All" checkbox
              CheckboxListTile(
                title: const Text(
                  "Select All",
                  style: TextStyle(
                      fontWeight:
                          FontWeight.bold), // Bold title for "Select All"
                ),
                value: _areAllSelected(),
                activeColor: AppColors.primary, // Use your primary color
                onChanged: _toggleSelectAll, // Select/deselect all
                controlAffinity:
                    ListTileControlAffinity.leading, // Checkbox on the left
              ),
              const Divider(height: 1, color: Colors.grey), // Optional divider
              ...widget.recipes.map((recipe) {
                return CheckboxListTile(
                  title: Text(recipe.title),
                  value: recipe.isSelected,
                  activeColor: AppColors
                      .primary, // Use your primary color for checkboxes
                  onChanged: (bool? value) {
                    _toggleIndividualRecipe(recipe, value);
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, // Checkbox at the start
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
