/// JEE Main exam date CMS defaults — matches `jeeprep_flutter/tool/seed_jee_cms.mjs`.
abstract final class JeeExamDateDefaults {
  static Map<String, dynamic> document() => {
        'nextExamDate': DateTime(2027, 1, 22).toIso8601String(),
        'introWhatIsPoints': const [
          'Full name - Joint Entrance Examination (Main), commonly called JEE Main',
          'Conducted by - National Testing Agency (NTA)',
          'Purpose - National entrance for B.E./B.Tech and B.Arch/B.Planning at NITs, IIITs, CFTIs; qualifier for JEE Advanced (IITs)',
          'Frequency - Twice a year (Session 1 and Session 2)',
          'Mode - Computer Based Test (CBT), except B.Arch drawing section where applicable',
        ],
        'keyFactsRows': const [
          {'detail': 'Maximum Marks (B.E./B.Tech)', 'value': '300 (100 per subject)'},
          {'detail': 'Subjects', 'value': 'Physics, Chemistry, Mathematics'},
          {
            'detail': 'Question types',
            'value': 'MCQ + numerical value questions (pattern per NTA notification)',
          },
          {
            'detail': 'Duration',
            'value': '3 hours (per paper; check official notification for B.Arch/B.Plan)',
          },
          {'detail': 'Attempts', 'value': 'No official attempt limit for JEE Main'},
          {'detail': 'Languages', 'value': '13 languages including English and Hindi'},
        ],
        'seatsBlurb':
            'JEE Main feeds admissions to 31 NITs, 26 IIITs, 29 CFTIs and other participating institutes. Top performers qualify for JEE Advanced and IIT admissions.',
        'eligibilityPoints': const [
          'Class 12 (or equivalent) with Physics, Mathematics and one additional subject as per NTA rules',
          'Minimum marks in Class 12 - typically 75% aggregate for General (65% for SC/ST); verify current NTA notice',
          'No upper age limit for JEE Main (confirm annually in official brochure)',
          'Appearing students may apply while Class 12 board exams are underway',
          'NRI and foreign-board students must meet subject-equivalence requirements',
        ],
        'qualifyingCutoffRows': const [
          {'category': 'General', 'marksBand': 'Varies by session - see NTA result'},
          {
            'category': 'OBC-NCL / SC / ST / EWS',
            'marksBand': 'Category-wise qualifying percentiles published by NTA',
          },
          {'category': 'PwD', 'marksBand': 'Separate qualifying criteria per official notification'},
        ],
        'admissionCutoffPoints': const [
          'JEE Main rank is used for JoSAA counselling for NITs, IIITs and CFTIs',
          'IIT admissions require qualifying JEE Advanced after meeting JEE Main cutoff',
          'Cutoffs vary widely by institute, branch and category',
          'Percentile (not raw marks alone) determines Advanced eligibility',
        ],
        'competitionPoints': const [
          'JEE Main sees lakhs of candidates each session',
          'NIT/IIT seat competition remains intense in popular branches',
          'Both Session 1 and Session 2 scores can be used - best of two applies where allowed',
        ],
        'patternRows': const [
          {'subject': 'Physics', 'marks': '30 questions - 100 marks'},
          {'subject': 'Chemistry', 'marks': '30 questions - 100 marks'},
          {'subject': 'Mathematics', 'marks': '30 questions - 100 marks'},
          {'subject': 'Total (B.E./B.Tech)', 'marks': '90 questions - 300 marks'},
        ],
        'patternBullets': const [
          'Syllabus - NCERT Class 11 & 12 PCM foundation plus JEE-oriented depth',
          'Numerical value questions require exact entry - practice calculator-free accuracy',
          'Mathematics often drives rank movement at competitive percentiles',
        ],
        'annualCycleRows': const [
          {'event': 'Session 1 registration', 'month': 'November - December'},
          {'event': 'Session 1 exam', 'month': 'January - February'},
          {'event': 'Session 2 registration', 'month': 'February - March'},
          {'event': 'Session 2 exam', 'month': 'April'},
          {'event': 'Result / percentile', 'month': 'After each session'},
          {'event': 'JEE Advanced (IIT)', 'month': 'May - June (eligible candidates)'},
          {'event': 'JoSAA counselling', 'month': 'June - July'},
        ],
        'counsellingPoints': const [
          'JoSAA - central counselling for NITs, IIITs, CFTIs and some other institutes',
          'CSAB - additional rounds for vacant seats after JoSAA',
          'State engineering counselling - separate registrations for state quota seats',
          'Documents - scorecard, admit card, marksheets, category certificates, photos, ID proofs',
        ],
        'collegeTypeRows': const [
          {
            'tier': 'IITs (via JEE Advanced)',
            'scoreBand': 'Top Advanced ranks',
            'fees': 'Rs.2L - Rs.2.5L approx. (4 years)',
            'notes': 'Most selective engineering pathway',
          },
          {
            'tier': 'NITs / IIITs (via JEE Main)',
            'scoreBand': 'Competitive percentile by branch',
            'fees': 'Rs.5L - Rs.10L approx. (4 years)',
            'notes': 'Strong ROI government-funded institutes',
          },
          {
            'tier': 'Private / deemed universities',
            'scoreBand': 'Varies by institute',
            'fees': 'Rs.12L - Rs.25L+ total',
            'notes': 'Verify accreditation and placement data',
          },
        ],
        'costRows': const [
          {'item': 'JEE Main registration (per session)', 'cost': 'Rs.1,000 (General) / Rs.500 (reserved)'},
          {'item': 'Coaching (2-year classroom)', 'cost': 'Rs.1.5L - Rs.4L'},
          {'item': 'Online coaching', 'cost': 'Rs.20k - Rs.1L'},
          {'item': 'Self-study + test series', 'cost': 'Rs.15k - Rs.50k'},
        ],
        'timelineRows': const [
          {'stage': 'Class 9-10', 'action': 'Build strong maths and science fundamentals'},
          {'stage': 'Class 11 start', 'action': 'Begin structured PCM rhythm aligned to JEE'},
          {'stage': 'Class 11-12', 'action': 'Daily problem practice + chapter tests'},
          {'stage': 'Final 6 months', 'action': 'Full mocks + weak-topic sprints'},
          {'stage': 'Minimum runway', 'action': '~2 years focused prep is typical for competitive outcomes'},
        ],
        'timelineNotes': const [
          'NCERT is the syllabus anchor - depth and speed both matter for JEE Main',
          'Consistency beats switching coaching brands mid-preparation',
        ],
        'costQualifier':
            'Total realistic prep envelope - Rs.30k - Rs.4L depending on coaching and test-series choices.',
        'nriPoints': const [
          'NRI students can appear for JEE Main subject to NTA eligibility rules',
          'DASA / CIWG and institute-specific NRI quotas have separate fee and document rules',
          'Overseas boards must map to PCM + English requirements',
          'Time-zone planning for online prep and mock tests abroad is critical',
        ],
        'mythRows': const [
          {
            'myth': 'JEE Main can be cracked in 3 months',
            'reality': 'Rare for top NIT/IIT outcomes without prior foundation',
          },
          {
            'myth': 'Only coaching toppers succeed',
            'reality': 'Self-study with disciplined mocks can also work',
          },
          {
            'myth': 'Math alone is enough',
            'reality': 'Physics and Chemistry balance is essential for stable percentiles',
          },
        ],
        'subjectImportanceBullets': const [
          'Mathematics often separates ranks in the 95+ percentile band',
          'Chemistry can be improved quickly with structured revision cycles',
          'Physics accuracy under time pressure drives many score swings',
        ],
        'fallbackPathsBullets': const [
          'Second JEE Main session - best-of-two attempt strategy',
          'State engineering entrances where applicable',
          'Re-attempt next year with gap-year planning',
          'Related B.Sc. / integrated programmes with transfer pathways',
        ],
        'footerLine':
            'Seed data - Jun 2026 | Replace with official NTA/JoSAA figures before production launch',
      };
}
