import 'package:flutter/material.dart';
import 'package:legumi/core/services/greenhouses_services.dart';
import 'package:legumi/features/analyses/components/SelectableOptionCard.dart';
import 'package:legumi/features/analyses/models/green_house_selection.dart';

class SelectedGreenHouseStep extends StatefulWidget {
  final ValueChanged<GreenhouseSelection?> onGreenhouseSelected;

  const SelectedGreenHouseStep({required this.onGreenhouseSelected});
  @override
  State<SelectedGreenHouseStep> createState() => _SelectedGreenHouseStepState();
}

class _SelectedGreenHouseStepState extends State<SelectedGreenHouseStep> {
  int? _selected;
  final _service = GreenhousesService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchMyGreenhouses();
      if (mounted)
        setState(() {
          _items = data;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_items.length, (i) {
        return SelectableOptionCard(
          title: _items[i]['name'] ?? "Sin nombre",
          subtitle: "${_items[i]['rows']}x${_items[i]['columns']}",
          isSelected: _selected == i,
          onTap: () {
            final item = _items[i];
            setState(() => _selected = i);
            widget.onGreenhouseSelected(
              GreenhouseSelection(
                id: item['id'],
                rows: item['rows'],
                name: item['name'],
                columns: item['columns'],
              ),
            );
          },
        );
      }),
    );
  }
}
