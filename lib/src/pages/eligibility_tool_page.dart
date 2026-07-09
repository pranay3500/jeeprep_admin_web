import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_db.dart';

class EligibilityToolPage extends StatefulWidget {
  const EligibilityToolPage({super.key});

  @override
  State<EligibilityToolPage> createState() => _EligibilityToolPageState();
}

class _EligibilityToolPageState extends State<EligibilityToolPage> {
  final _coll = FirestoreDb.instance.collection('cms_eligibility_rules');

  bool _initialized = false;
  bool _saving = false;
  String? _status;
  String? _error;

  final _thresholdGeneral = TextEditingController(text: '50');
  final _thresholdObc = TextEditingController(text: '40');
  final _thresholdPwd = TextEditingController(text: '45');
  final _logicJson = TextEditingController();

  final Map<String, TextEditingController> _plainCtrls = {};
  final Map<String, TextEditingController> _legalCtrls = {};
  static const List<String> _defaultRuleIds = [
    'R1_AGE_FAIL',
    'R2_NATIONALITY_DOC_FAIL',
    'R3_STUDY_ABROAD_FAIL',
    'R4_SUBJECT_FAIL',
    'R5_ACADEMIC_SCORE_FAIL',
    'R6_PROVISIONAL_RESULT',
    'R7_EQUIVALENCE_REQUIRED',
    'R8_JEE_MAIN_FAIL',
    'R0_CIWG_NOT_REQUESTED',
    'R0_CIWG_CATEGORY_FAIL',
    'R9_CIWG_PARENT_FAIL',
    'R9_CIWG_DOCS_REQUIRED',
    'CIWG_DOUBLE_TAG_SELECTED',
  ];
  static const Map<String, Map<String, String>> _defaultRuleMessages = {
    'R1_AGE_FAIL': {
      'plain': 'Age criterion failed: candidate must be born on or after 1 Oct 2001.',
      'legal': 'DASA 2026 UG age cutoff uses the Class X/government DOB record.',
    },
    'R2_NATIONALITY_DOC_FAIL': {
      'plain': 'Nationality proof is missing or expired.',
      'legal': 'Valid passport/OCI documentation is mandatory for DASA verification.',
    },
    'R3_STUDY_ABROAD_FAIL': {
      'plain': 'NRI study-abroad requirement is not satisfied.',
      'legal': 'NRI route needs 2 years abroad within last 8 years including Class XI/XII, and Class XII passed from abroad.',
    },
    'R4_SUBJECT_FAIL': {
      'plain': 'Selected program subject requirement is not met.',
      'legal': 'B.E./B.Tech requires Physics+Math+one optional; B.Arch requires PCM; B.Plan requires Math.',
    },
    'R5_ACADEMIC_SCORE_FAIL': {
      'plain': 'Minimum Class XII marks/CGPA threshold is not met.',
      'legal': 'DASA requires either >=75% aggregate (best 5 subjects) or >=7.5 CGPA.',
    },
    'R6_PROVISIONAL_RESULT': {
      'plain': 'Class XII result is provisional (awaited/reevaluation pending).',
      'legal': 'Final eligible result must be submitted before DASA deadline, else candidature may be cancelled.',
    },
    'R7_EQUIVALENCE_REQUIRED': {
      'plain': 'AIU equivalence documentation may be required.',
      'legal': 'Boards outside AIU-recognized systems require equivalence at document stage.',
    },
    'R8_JEE_MAIN_FAIL': {
      'plain': 'Valid JEE Main 2026 paper score for selected program is missing.',
      'legal': 'Paper mapping: B.E./B.Tech=Paper 1, B.Arch=Paper 2A, B.Plan=Paper 2B.',
    },
    'R0_CIWG_NOT_REQUESTED': {
      'plain': 'CIWG tag was not requested in this run.',
      'legal': 'CIWG verdict remains advisory unless CIWG option is selected.',
    },
    'R0_CIWG_CATEGORY_FAIL': {
      'plain': 'CIWG can only be applied with NRI category.',
      'legal': 'FN/OCI_F/OCI_I paths cannot claim CIWG tag.',
    },
    'R9_CIWG_PARENT_FAIL': {
      'plain': 'Parent Gulf-employment criterion for CIWG is not satisfied.',
      'legal': 'Parent must work/worked in one of 8 eligible Gulf countries up to any date in admission year.',
    },
    'R9_CIWG_DOCS_REQUIRED': {
      'plain': 'CIWG supporting document set is incomplete.',
      'legal': 'Parent passport, visa, work permit, and employer certificate are required for CIWG verification.',
    },
    'CIWG_DOUBLE_TAG_SELECTED': {
      'plain': 'Double Tag selected: CIWG + Non-CIWG consideration enabled.',
      'legal': 'Double Tag uses higher Non-CIWG fee upfront and supports both choice pools.',
    },
  };

  @override
  void dispose() {
    _thresholdGeneral.dispose();
    _thresholdObc.dispose();
    _thresholdPwd.dispose();
    _logicJson.dispose();
    for (final c in _plainCtrls.values) {
      c.dispose();
    }
    for (final c in _legalCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (_initialized) return;
    _initialized = true;
    final logic = <String, dynamic>{};
    for (final d in docs) {
      final data = d.data();
      if (d.id == 'thresholds') {
        _thresholdGeneral.text = (data['aggregate_min_percent'] ?? 75).toString();
        _thresholdObc.text = (data['cgpa_min_times10'] ?? 75).toString();
        _thresholdPwd.text = (data['reserved_numeric'] ?? 0).toString();
        continue;
      }
      if (d.id == 'logic_config') {
        logic.addAll(data);
        continue;
      }
      _plainCtrls[d.id] = TextEditingController(
        text: (data['plain'] ?? '').toString(),
      );
      _legalCtrls[d.id] = TextEditingController(
        text: (data['legal'] ?? '').toString(),
      );
    }

    if (logic.isEmpty) {
      logic.addAll(const {
        'version': 'dasa_ciwg_2026_v2',
        'lastUpdated': '2026-07-09',
        'ageRules': {
          'cutoffDobInclusive': '2001-10-01',
        },
        'academicRules': {
          'minAggregateBest5': 75,
          'minCgpa10Scale': 7.5,
        },
        'ciwgEligibleCountries': [
          'United Arab Emirates',
          'Bahrain',
          'Iraq',
          'Iran',
          'Kuwait',
          'Oman',
          'Qatar',
          'Saudi Arabia',
        ],
        'flagSeverity': {
          'neet': {
            'hardFail': [
              'R1_AGE_FAIL',
              'R2_NATIONALITY_DOC_FAIL',
              'R3_STUDY_ABROAD_FAIL',
              'R4_SUBJECT_FAIL',
              'R5_ACADEMIC_SCORE_FAIL',
              'R8_JEE_MAIN_FAIL',
            ],
            'conditional': [
              'R6_PROVISIONAL_RESULT',
              'R7_EQUIVALENCE_REQUIRED',
            ],
            'advisory': [],
          },
          'nri': {
            'hardFail': [
              'R0_CIWG_CATEGORY_FAIL',
              'R9_CIWG_PARENT_FAIL',
            ],
            'conditional': [
              'R9_CIWG_DOCS_REQUIRED',
              'R0_CIWG_NOT_REQUESTED',
            ],
            'advisory': ['CIWG_DOUBLE_TAG_SELECTED'],
          },
        },
      });
    }
    for (final id in _defaultRuleIds) {
      final defaults = _defaultRuleMessages[id] ?? const <String, String>{};
      _plainCtrls.putIfAbsent(
        id,
        () => TextEditingController(text: defaults['plain'] ?? ''),
      );
      _legalCtrls.putIfAbsent(
        id,
        () => TextEditingController(text: defaults['legal'] ?? ''),
      );
      if (_plainCtrls[id]!.text.trim().isEmpty && (defaults['plain'] ?? '').isNotEmpty) {
        _plainCtrls[id]!.text = defaults['plain']!;
      }
      if (_legalCtrls[id]!.text.trim().isEmpty && (defaults['legal'] ?? '').isNotEmpty) {
        _legalCtrls[id]!.text = defaults['legal']!;
      }
    }
    _logicJson.text = const JsonEncoder.withIndent('  ').convert(logic);
  }

  Future<void> _save() async {
    Map<String, dynamic> logic;
    try {
      final decoded = jsonDecode(_logicJson.text);
      if (decoded is! Map) throw const FormatException('JSON must be object');
      logic = Map<String, dynamic>.from(decoded);
    } catch (e) {
      setState(() {
        _error = 'Logic JSON is invalid: $e';
        _status = null;
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
      _status = null;
    });

    try {
      final batch = FirestoreDb.instance.batch();
      batch.set(_coll.doc('thresholds'), {
        'aggregate_min_percent':
            double.tryParse(_thresholdGeneral.text.trim()) ?? 75,
        'cgpa_min_times10': double.tryParse(_thresholdObc.text.trim()) ?? 75,
        'reserved_numeric': double.tryParse(_thresholdPwd.text.trim()) ?? 0,
      }, SetOptions(merge: true));
      batch.set(_coll.doc('logic_config'), logic, SetOptions(merge: true));

      for (final id in _plainCtrls.keys) {
        batch.set(_coll.doc(id), {
          'plain': _plainCtrls[id]!.text.trim(),
          'legal': _legalCtrls[id]!.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      setState(() => _status = 'Eligibility tool settings saved.');
    } catch (e) {
      setState(() => _error = 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _coll.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_initialized) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? const [];
        _hydrate(docs);
        final ruleIds = _plainCtrls.keys.toList()..sort();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Eligibility Tool',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage DASA/CIWG checker logic and all “Read Legal Detail” text from admin. Changes sync to app via Firestore.',
            ),
            if (_status != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _status!,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            _sectionCard(
              title: 'Reference thresholds',
              child: Column(
                children: [
                  _field(_thresholdGeneral, 'Class XII aggregate minimum (%)'),
                  const SizedBox(height: 10),
                  _field(_thresholdObc, 'Class XII CGPA minimum (10 scale x10)'),
                  const SizedBox(height: 10),
                  _field(_thresholdPwd, 'Reserved for future use'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Logic Configuration (JSON)',
              subtitle:
                  'Defines DASA/CIWG decision behavior in app (age cutoff, score rules, CIWG countries, rule severity).',
              child: TextFormField(
                controller: _logicJson,
                minLines: 12,
                maxLines: 20,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '{\n  "requiresBothYearsBoards": [...]\n}',
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Rule Messages',
              subtitle:
                  'Edit the plain text and “Read Legal Detail” content shown in the app result cards.',
              child: ruleIds.isEmpty
                  ? const Text(
                      'No rules found yet. Add rules and save once to initialize.',
                    )
                  : Column(
                      children: [
                        for (final id in ruleIds) ...[
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: const EdgeInsets.only(bottom: 12),
                            title: Text(
                              id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4527A0),
                              ),
                            ),
                            subtitle: Text(
                              _plainCtrls[id]!.text.trim().isEmpty
                                  ? 'Tap to add message'
                                  : _plainCtrls[id]!.text.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              _field(_plainCtrls[id]!, 'Plain message'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _legalCtrls[id],
                                minLines: 3,
                                maxLines: 8,
                                decoration: const InputDecoration(
                                  labelText: 'Read Legal Detail content',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 36),
          ],
        );
      },
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}

