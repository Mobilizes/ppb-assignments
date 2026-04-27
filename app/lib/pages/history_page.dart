import 'package:app/models/history.dart';
import 'package:app/repositories/history_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Set<String> _selectedIds = {};
  final Set<String> _previousSelectedIds = {};

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<HistoryRepository>();
    final isSelectionMode = _selectedIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _clearSelection,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
        title: TextButton(
          onPressed: isSelectionMode
              ? () {
                  if (_selectedIds.length == repository.currentHistory.length) {
                    _clearSelection();
                    _selectAll(_previousSelectedIds.toList());
                  } else {
                    _previousSelectedIds
                      ..clear()
                      ..addAll(_selectedIds);
                    _selectAll(
                      repository.currentHistory.map((h) => h.id).toList(),
                    );
                  }
                }
              : null,
          child: Text(
            isSelectionMode
                ? '${_selectedIds.length} selected'
                : 'High Decibel History',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () async {
                await repository.deleteHistories(_selectedIds.toList());
                _clearSelection();
              },
            ),
        ],
      ),
      body: repository.currentHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: Colors.grey.withAlpha(50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No history recorded yet.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: repository.currentHistory.length,
              itemBuilder: (context, index) {
                final history = repository.currentHistory[index];
                final isSelected = _selectedIds.contains(history.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isSelected
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (isSelectionMode) {
                        _toggleSelection(history.id);
                      }
                    },
                    onLongPress: () {
                      if (!isSelectionMode) {
                        _toggleSelection(history.id);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelection(history.id),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volume_up_rounded,
                                  color: Colors.red,
                                ),
                              ),
                        title: Text(
                          '${history.maxDb.isFinite ? history.maxDb.toStringAsFixed(1) : '0.0'} dB',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(history.created),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        trailing: isSelectionMode
                            ? null
                            : IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  repository.deleteHistory(history.id);
                                },
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<String> ids) {
    setState(() {
      _selectedIds.addAll(ids);
    });
  }
}
