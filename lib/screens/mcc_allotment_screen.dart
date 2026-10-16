import 'package:flutter/material.dart';
import '../models/mcc_allotment.dart';
import '../services/mcc_allotment_service.dart';

class MccAllotmentScreen extends StatefulWidget {
  const MccAllotmentScreen({super.key});

  @override
  State<MccAllotmentScreen> createState() => _MccAllotmentScreenState();
}

class _MccAllotmentScreenState extends State<MccAllotmentScreen> {
  final _service = MccAllotmentService();
  final _rankController = TextEditingController();
  final _collegeController = TextEditingController();

  List<MccAllotment> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  Future<void> _search() async {
    final rankText = _rankController.text.trim();
    final college = _collegeController.text.trim();

    if (rankText.isEmpty && college.isEmpty) {
      setState(() => _error = 'AIR Rank या College Name भरें।');
      return;
    }

    if (rankText.isNotEmpty && num.tryParse(rankText) == null) {
      setState(() => _error = 'Valid AIR Rank दर्ज करें।');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });

    try {
      final results = await _service.search(
        rank: rankText.isEmpty ? null : num.parse(rankText),
        college: college.isEmpty ? null : college,
      );

      if (!mounted) return;
      setState(() {
        _results = results.take(100).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Data load नहीं हुआ: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _rankController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MCC Allotment — 2025')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _rankController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NEET All India Rank (AIR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _collegeController,
              decoration: const InputDecoration(
                labelText: 'College Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _search,
                child: const Text('Search Allotments'),
              ),
            ),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!),
            if (_searched && !_loading && _error == null)
              Text('Results: ${_results.length} (maximum 100 shown)'),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.collegeRaw),
                      subtitle: Text(
                        'AIR: ${item.rank} • ${item.course}\n'
                        'Quota: ${item.quota ?? "Not specified"}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
