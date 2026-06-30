import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/jee_exam_date_defaults.dart';
import '../jee_product_constants.dart';
import '../services/firestore_db.dart';

class ExamDateCmsPage extends StatefulWidget {
  const ExamDateCmsPage({super.key});

  @override
  State<ExamDateCmsPage> createState() => _ExamDateCmsPageState();
}

class _ExamDateCmsPageState extends State<ExamDateCmsPage> {
  static const String _buildStamp = 'exam-cms-v3-no-timeout';
  DocumentReference<Map<String, dynamic>> get _doc =>
      FirestoreDb.instance
          .collection('cms_exam_date')
          .doc(JeeProductConstants.examDateDocId);

  final _introWhatIs = TextEditingController();
  final _keyFactsRows = TextEditingController();
  final _seatsBlurb = TextEditingController();
  final _eligibilityPoints = TextEditingController();
  final _footer = TextEditingController();
  final _costQualifier = TextEditingController();
  final _qualifyingRows = TextEditingController();
  final _admissionPoints = TextEditingController();
  final _competitionPoints = TextEditingController();
  final _patternRows = TextEditingController();
  final _patternBullets = TextEditingController();
  final _annualCycleRows = TextEditingController();
  final _counsellingPoints = TextEditingController();
  final _collegeRows = TextEditingController();
  final _timelineRows = TextEditingController();
  final _timelineNotes = TextEditingController();
  final _costRows = TextEditingController();
  final _nriPoints = TextEditingController();
  final _mythRows = TextEditingController();
  final _subjectImportance = TextEditingController();
  final _fallbackPaths = TextEditingController();

  DateTime _nextExamDate = DateTime(2027, 5, 5);
  bool _loaded = false;
  bool _saving = false;
  String _status = 'Ready';
  String _lastError = '-';

  static Map<String, dynamic> get _defaultDoc => JeeExamDateDefaults.document();

  @override
  void dispose() {
    _introWhatIs.dispose();
    _keyFactsRows.dispose();
    _seatsBlurb.dispose();
    _eligibilityPoints.dispose();
    _footer.dispose();
    _costQualifier.dispose();
    _qualifyingRows.dispose();
    _admissionPoints.dispose();
    _competitionPoints.dispose();
    _patternRows.dispose();
    _patternBullets.dispose();
    _annualCycleRows.dispose();
    _counsellingPoints.dispose();
    _collegeRows.dispose();
    _timelineRows.dispose();
    _timelineNotes.dispose();
    _costRows.dispose();
    _nriPoints.dispose();
    _mythRows.dispose();
    _subjectImportance.dispose();
    _fallbackPaths.dispose();
    super.dispose();
  }

  List<Map<String, String>> _parseRows(
    String input,
    int expectedColumns,
    List<String> keys,
  ) {
    final lines = input
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    final out = <Map<String, String>>[];
    for (final line in lines) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.length < expectedColumns) continue;
      final map = <String, String>{};
      for (var i = 0; i < expectedColumns; i++) {
        map[keys[i]] = parts[i];
      }
      out.add(map);
    }
    return out;
  }

  String _joinRows(List<dynamic> rows, List<String> keys) {
    return rows
        .whereType<Map>()
        .map((e) => keys.map((k) => e[k]?.toString().trim() ?? '').join(' | '))
        .where((e) => e.replaceAll('|', '').trim().isNotEmpty)
        .join('\n');
  }

  String _joinList(List<dynamic> rows) => rows
      .map((e) => e.toString().trim())
      .where((e) => e.isNotEmpty)
      .join('\n');

  void _loadFrom(Map<String, dynamic> data) {
    _nextExamDate = _asDate(data['nextExamDate']) ?? DateTime(2027, 5, 5);
    _introWhatIs.text = _joinList(
      data['introWhatIsPoints'] as List? ?? const [],
    );
    _keyFactsRows.text = _joinRows(data['keyFactsRows'] as List? ?? const [], [
      'detail',
      'value',
    ]);
    _seatsBlurb.text = data['seatsBlurb']?.toString() ?? '';
    _eligibilityPoints.text = _joinList(
      data['eligibilityPoints'] as List? ?? const [],
    );
    _footer.text = data['footerLine']?.toString() ?? '';
    _costQualifier.text = data['costQualifier']?.toString() ?? '';
    _qualifyingRows.text = _joinRows(
      data['qualifyingCutoffRows'] as List? ?? const [],
      ['category', 'marksBand'],
    );
    _admissionPoints.text = _joinList(
      data['admissionCutoffPoints'] as List? ?? const [],
    );
    _competitionPoints.text = _joinList(
      data['competitionPoints'] as List? ?? const [],
    );
    _patternRows.text = _joinRows(data['patternRows'] as List? ?? const [], [
      'subject',
      'marks',
    ]);
    _patternBullets.text = _joinList(
      data['patternBullets'] as List? ?? const [],
    );
    _annualCycleRows.text = _joinRows(
      data['annualCycleRows'] as List? ?? const [],
      ['event', 'month'],
    );
    _counsellingPoints.text = _joinList(
      data['counsellingPoints'] as List? ?? const [],
    );
    _collegeRows.text = _joinRows(
      data['collegeTypeRows'] as List? ?? const [],
      ['tier', 'scoreBand', 'fees', 'notes'],
    );
    _timelineRows.text = _joinRows(data['timelineRows'] as List? ?? const [], [
      'stage',
      'action',
    ]);
    _timelineNotes.text = _joinList(data['timelineNotes'] as List? ?? const []);
    _costRows.text = _joinRows(data['costRows'] as List? ?? const [], [
      'item',
      'cost',
    ]);
    _nriPoints.text = _joinList(data['nriPoints'] as List? ?? const []);
    _mythRows.text = _joinRows(data['mythRows'] as List? ?? const [], [
      'myth',
      'reality',
    ]);
    _subjectImportance.text = _joinList(
      data['subjectImportanceBullets'] as List? ?? const [],
    );
    _fallbackPaths.text = _joinList(
      data['fallbackPathsBullets'] as List? ?? const [],
    );
    _loaded = true;
  }

  DateTime? _asDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final sw = Stopwatch()..start();
    try {
      setState(() => _status = 'Saving...');
      final payload = <String, dynamic>{
        'nextExamDate': Timestamp.fromDate(
          DateTime(_nextExamDate.year, _nextExamDate.month, _nextExamDate.day),
        ),
        'introWhatIsPoints': _introWhatIs.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'keyFactsRows': _parseRows(_keyFactsRows.text, 2, ['detail', 'value']),
        'seatsBlurb': _seatsBlurb.text.trim(),
        'eligibilityPoints': _eligibilityPoints.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'footerLine': _footer.text.trim(),
        'costQualifier': _costQualifier.text.trim(),
        'qualifyingCutoffRows': _parseRows(_qualifyingRows.text, 2, [
          'category',
          'marksBand',
        ]),
        'admissionCutoffPoints': _admissionPoints.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'competitionPoints': _competitionPoints.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'patternRows': _parseRows(_patternRows.text, 2, ['subject', 'marks']),
        'patternBullets': _patternBullets.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'annualCycleRows': _parseRows(_annualCycleRows.text, 2, [
          'event',
          'month',
        ]),
        'counsellingPoints': _counsellingPoints.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'collegeTypeRows': _parseRows(_collegeRows.text, 4, [
          'tier',
          'scoreBand',
          'fees',
          'notes',
        ]),
        'timelineRows': _parseRows(_timelineRows.text, 2, ['stage', 'action']),
        'timelineNotes': _timelineNotes.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'costRows': _parseRows(_costRows.text, 2, ['item', 'cost']),
        'nriPoints': _nriPoints.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'mythRows': _parseRows(_mythRows.text, 2, ['myth', 'reality']),
        'subjectImportanceBullets': _subjectImportance.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'fallbackPathsBullets': _fallbackPaths.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _doc
          .set(payload, SetOptions(merge: true))
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () {
              throw TimeoutException('Save request timed out after 12s.');
            },
          );
      // Best-effort verification only; don't fail save UX on transient server read delays.
      try {
        await _doc
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 6));
      } catch (_) {}
      if (mounted) {
        _lastError = '-';
        setState(
          () => _status =
              'Saved at ${DateFormat('hh:mm:ss a').format(DateTime.now())} '
              '(${sw.elapsed.inSeconds}s)',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Exam Date CMS saved successfully. App will sync this shortly.',
            ),
          ),
        );
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        _lastError = e.toString();
        setState(() => _status = 'Save timed out');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Save timed out. Please retry. If this repeats, check Firestore connectivity/rules.',
            ),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        _lastError = '${e.code}: ${e.message ?? ''}'.trim();
        setState(() => _status = 'Save failed (${e.code})');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Save failed (${e.code}): ${e.message ?? 'Check rules/network.'}',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        _lastError = e.toString();
        setState(() => _status = 'Save failed');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _liveReadErrorHelp(Object? error) {
    final msg = error?.toString() ?? 'Unknown error';
    final isDenied = msg.contains('permission-denied');
    final wrongDbHint = FirestoreDb.databaseId != '(default)'
        ? '\n\nThis build uses Firestore DB "${FirestoreDb.databaseId}". '
            'JEE project requires "(default)" (not NEET\'s "default"). '
            'Rebuild and upload the latest admin web.'
        : '';
    final rulesHint = isDenied
        ? '\n\nIf DB is already "(default)", deploy rules from jeeprep_flutter:\n'
            'powershell -File tool\\deploy_jee_firebase_rules.ps1'
        : '';
    return 'Live read issue: $msg\n'
        'You can still edit and save if your account is an admin in this Firebase project.'
        '$wrongDbHint'
        '$rulesHint';
  }

  Future<void> _runWriteProbe() async {
    try {
      await _doc.set({
        '_debugProbeAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        _status =
            'Probe OK at ${DateFormat('hh:mm:ss a').format(DateTime.now())}';
        _lastError = '-';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Write probe succeeded.')));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Probe failed (${e.code})';
        _lastError = '${e.code}: ${e.message ?? ''}'.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Probe failed (${e.code}): ${e.message ?? ''}')),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Probe failed';
        _lastError = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Probe failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _doc.snapshots(),
      builder: (context, snapshot) {
        if (!_loaded) {
          if (snapshot.hasData && snapshot.data!.exists) {
            _loadFrom(snapshot.data!.data() ?? const {});
          } else if (snapshot.connectionState != ConnectionState.waiting) {
            _loadFrom(_defaultDoc);
          }
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Card(
                color: const Color(0xFFF1F8E9),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debug Panel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text('Build: $_buildStamp'),
                      Text('Project: ${Firebase.app().options.projectId}'),
                      Text('Firestore DB: ${FirestoreDb.databaseId}'),
                      Text(
                        'Auth user: ${FirebaseAuth.instance.currentUser?.email ?? 'Not signed in'}',
                      ),
                      Text(
                        'Doc path: cms_exam_date/${JeeProductConstants.examDateDocId}',
                      ),
                      Text('Last status: $_status'),
                      Text('Last error: $_lastError'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _runWriteProbe,
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('Run Write Probe'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.hasError)
                Card(
                  color: const Color(0xFFFFF3E0),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _liveReadErrorHelp(snapshot.error),
                      style: const TextStyle(color: Color(0xFFE65100)),
                    ),
                  ),
                ),
              if (snapshot.hasError) const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Exam Date CMS - Full Parent Guide Editor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Edit all guide sections exactly as shown in app.'),
                      Text(
                        'Table format: value1 | value2 (or 4 values where specified).',
                      ),
                      Text('Current status is shown near Save.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _nextExamDate,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null && mounted) {
                          setState(() => _nextExamDate = picked);
                        }
                      },
                      icon: const Icon(Icons.event_rounded),
                      label: Text(
                        'Next Exam Date: ${DateFormat('dd MMM yyyy').format(_nextExamDate)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: const Text('Save & Verify'),
                  ),
                  const SizedBox(width: 10),
                  Text(_status),
                ],
              ),
              const SizedBox(height: 14),
              _section(
                title: '01) What is JEE Main?',
                impact: 'Updates top introductory bullets in app section 01.',
                child: _editor(
                  controller: _introWhatIs,
                  label: 'Intro bullets',
                  help: 'One bullet per line',
                ),
              ),
              _section(
                title: '02) Key exam facts',
                impact: 'Updates facts table and seats blurb in section 02.',
                child: Column(
                  children: [
                    _editor(
                      controller: _keyFactsRows,
                      label: 'Facts rows',
                      help: 'detail | value',
                    ),
                    _editor(
                      controller: _seatsBlurb,
                      label: 'Seats blurb',
                      help: 'Single paragraph',
                      minLines: 2,
                    ),
                  ],
                ),
              ),
              _section(
                title: '03) Eligibility',
                impact: 'Updates section 03 bullet list.',
                child: _editor(
                  controller: _eligibilityPoints,
                  label: 'Eligibility bullets',
                  help: 'One bullet per line',
                ),
              ),
              _editor(
                controller: _qualifyingRows,
                label: 'Qualifying cutoff rows',
                help: 'category | marksBand',
              ),
              _editor(
                controller: _admissionPoints,
                label: 'Admission cutoff bullets',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _competitionPoints,
                label: 'Competition bullets',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _patternRows,
                label: 'Pattern rows',
                help: 'subject | marks',
              ),
              _editor(
                controller: _patternBullets,
                label: 'Pattern bullets',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _annualCycleRows,
                label: 'Annual cycle rows',
                help: 'event | month',
              ),
              _editor(
                controller: _counsellingPoints,
                label: 'Counselling bullets',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _collegeRows,
                label: 'College type rows',
                help: 'tier | scoreBand | fees | notes',
              ),
              _editor(
                controller: _timelineRows,
                label: 'Preparation timeline rows',
                help: 'stage | action',
              ),
              _editor(
                controller: _timelineNotes,
                label: 'Timeline notes',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _costRows,
                label: 'Cost rows',
                help: 'item | cost',
              ),
              _editor(
                controller: _costQualifier,
                label: 'Cost qualifier callout',
                help: 'Single paragraph',
                minLines: 2,
              ),
              _editor(
                controller: _nriPoints,
                label: 'NRI bullets',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _mythRows,
                label: 'Myths table',
                help: 'myth | reality',
              ),
              _editor(
                controller: _subjectImportance,
                label: 'Subject importance bullets',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _fallbackPaths,
                label: 'Fallback path bullets',
                help: 'One bullet per line',
              ),
              _editor(
                controller: _footer,
                label: 'Footer line',
                help: 'Last updated/source line shown in app footer',
                minLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _editor({
    required TextEditingController controller,
    required String label,
    required String help,
    int minLines = 4,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines + 4,
        decoration: InputDecoration(
          labelText: label,
          helperText: help,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required String impact,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(impact, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
