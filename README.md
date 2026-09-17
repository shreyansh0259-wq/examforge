# ExamForge v2 — Working Flutter Android MVP

## Included
- Home
- Exam selection: NEET, JEE Main, JEE Advanced, UPSC
- Subject/chapter filtering
- Question count and time limit
- Difficulty: Easy / Medium / Hard / Mixed
- Real countdown timer with auto-submit
- Save & Next / Previous
- Mark for Review
- Question palette with status
- Submit confirmation
- Result: score, correct, wrong, unattempted, accuracy
- Persistent local history using SharedPreferences
- Retake from history
- Demo question generator with exam/subject/chapter/difficulty metadata

## Run
flutter pub get
flutter run

## Production work still required
1. Supabase/PostgreSQL backend
2. User authentication and cloud sync
3. Real licensed PYQ/question bank
4. Exam-specific marking rules (NEET/JEE Main/JEE Advanced/UPSC)
5. Server-side exact filtering and non-repeat engine
6. Detailed chapter/topic analytics
7. Attempt-vs-attempt comparison
8. Admin question import/tagging
9. Secure answer handling and anti-cheat measures
10. Release build, app icon, onboarding and Play Store configuration

The included questions are generated demo placeholders, not real PYQs or coaching material.
