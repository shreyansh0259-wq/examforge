
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryStore.load();
  runApp(const ExamForgeApp());
}

class Exam {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<Subject> subjects;
  const Exam(this.name, this.subtitle, this.icon, this.subjects);
}

class Subject {
  final String name;
  final IconData icon;
  final List<String> chapters;
  const Subject(this.name, this.icon, this.chapters);
}

const exams = [
  Exam('NEET', 'Physics • Chemistry • Biology', Icons.biotech, [
    Subject('Physics', Icons.bolt, ['Units & Measurements','Kinematics','Laws of Motion','Work, Energy & Power','Rotational Motion']),
    Subject('Chemistry', Icons.science, ['Some Basic Concepts','Atomic Structure','Chemical Bonding','Thermodynamics','Organic Chemistry']),
    Subject('Biology', Icons.eco, ['The Living World','Cell: Structure & Function','Plant Physiology','Human Physiology','Genetics & Evolution']),
  ]),
  Exam('JEE Main', 'Physics • Chemistry • Mathematics', Icons.functions, [
    Subject('Physics', Icons.bolt, ['Units & Measurements','Kinematics','NLM','Work, Energy & Power','Rotational Motion']),
    Subject('Chemistry', Icons.science, ['Mole Concept','Atomic Structure','Chemical Bonding','Equilibrium','Organic Chemistry']),
    Subject('Mathematics', Icons.calculate, ['Sets & Functions','Complex Numbers','Quadratic Equations','Matrices & Determinants','Calculus']),
  ]),
  Exam('JEE Advanced', 'Advanced PCM practice', Icons.school, [
    Subject('Physics', Icons.bolt, ['Mechanics','Electrodynamics','Optics','Thermodynamics','Modern Physics']),
    Subject('Chemistry', Icons.science, ['Physical Chemistry','Inorganic Chemistry','Organic Chemistry']),
    Subject('Mathematics', Icons.calculate, ['Algebra','Coordinate Geometry','Calculus','Vectors & 3D']),
  ]),
  Exam('UPSC', 'General Studies & CSAT', Icons.account_balance, [
    Subject('History', Icons.museum, ['Ancient India','Medieval India','Modern India','World History']),
    Subject('Geography', Icons.public, ['Physical Geography','Indian Geography','World Geography']),
    Subject('Polity', Icons.gavel, ['Constitution','Parliament','Judiciary','Federalism']),
    Subject('Economy', Icons.trending_up, ['Basic Economics','Banking','Fiscal Policy','External Sector']),
  ]),
];

class Question {
  final String id, text, chapter, difficulty;
  final List<String> options;
  final int correct;
  const Question(this.id,this.text,this.chapter,this.difficulty,this.options,this.correct);
  Map<String,dynamic> toJson()=>{'id':id,'text':text,'chapter':chapter,'difficulty':difficulty,'options':options,'correct':correct};
  factory Question.fromJson(Map<String,dynamic> j)=>Question(j['id'],j['text'],j['chapter'],j['difficulty'],List<String>.from(j['options']),j['correct']);
}

class TestConfig {
  final String exam;
  final Map<String,List<String>> chapters;
  final int count, minutes;
  final String difficulty;
  TestConfig({required this.exam,required this.chapters,required this.count,required this.minutes,required this.difficulty});
  Map<String,dynamic> toJson()=>{'exam':exam,'chapters':chapters,'count':count,'minutes':minutes,'difficulty':difficulty};
  factory TestConfig.fromJson(Map<String,dynamic> j)=>TestConfig(
    exam:j['exam'], chapters:(j['chapters'] as Map).map((k,v)=>MapEntry(k,List<String>.from(v))),
    count:j['count'], minutes:j['minutes'], difficulty:j['difficulty']);
}

class Attempt {
  final String id;
  final TestConfig config;
  final List<Question> questions;
  final List<int?> answers;
  final List<bool> review;
  final int seconds;
  final DateTime date;
  Attempt({required this.id,required this.config,required this.questions,required this.answers,required this.review,required this.seconds,required this.date});
  int get attempted=>answers.where((x)=>x!=null).length;
  int get correct=>List.generate(questions.length,(i)=>answers[i]==questions[i].correct?1:0).fold(0,(a,b)=>a+b);
  int get incorrect=>attempted-correct;
  int get unattempted=>questions.length-attempted;
  int get score=>correct*4-incorrect;
  Map<String,dynamic> toJson()=>{'id':id,'config':config.toJson(),'questions':questions.map((q)=>q.toJson()).toList(),'answers':answers,'review':review,'seconds':seconds,'date':date.toIso8601String()};
  factory Attempt.fromJson(Map<String,dynamic> j)=>Attempt(
    id:j['id'],config:TestConfig.fromJson(j['config']),
    questions:(j['questions'] as List).map((x)=>Question.fromJson(x)).toList(),
    answers:(j['answers'] as List).map<int?>((x)=>x==null?null:x as int).toList(),
    review:List<bool>.from(j['review']),seconds:j['seconds'],date:DateTime.parse(j['date']));
}

class HistoryStore {
  static List<Attempt> attempts=[];
  static SharedPreferences? _prefs;
  static Future<void> load() async {
    _prefs=await SharedPreferences.getInstance();
    final raw=_prefs!.getStringList('attempts')??[];
    attempts=raw.map((s)=>Attempt.fromJson(jsonDecode(s))).toList();
  }
  static Future<void> save(Attempt a) async {
    attempts.insert(0,a);
    await _prefs?.setStringList('attempts',attempts.map((x)=>jsonEncode(x.toJson())).toList());
  }
}

List<Question> generate(TestConfig c) {
  final rng=Random();
  final selected=c.chapters.values.expand((x)=>x).toSet();
  final difficulties=c.difficulty=='Mixed'?{'Easy','Medium','Hard'}:{c.difficulty};
  final pool=<Question>[];
  for(final ch in selected) {
    for(final d in difficulties) {
      for(int n=0;n<4;n++) {
        pool.add(Question(
          '${ch}_${d}_$n',
          'Practice question from $ch at $d difficulty. Which option is correct?',
          ch,d,
          ['Option A','Option B','Option C','Option D'],
          (n + d.length + ch.length) % 4,
        ));
      }
    }
  }
  pool.shuffle(rng);
  final result=<Question>[];
  final used=HistoryStore.attempts.expand((a)=>a.questions.map((q)=>q.id)).toSet();
  result.addAll(pool.where((q)=>!used.contains(q.id)));
  if(result.length<c.count) result.addAll(pool.where((q)=>used.contains(q.id)));
  return result.take(c.count).toList();
}

class ExamForgeApp extends StatelessWidget {
  const ExamForgeApp({super.key});
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,title:'ExamForge',
    theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.indigo,scaffoldBackgroundColor:const Color(0xfff7f8fc)),
    home:const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('ExamForge',style:TextStyle(fontWeight:FontWeight.w800)),actions:[
      IconButton(icon:const Icon(Icons.history),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const HistoryScreen())))
    ]),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      Text('Custom tests. Your syllabus. Your difficulty.',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:8),const Text('Build focused practice tests and track every attempt.'),
      const SizedBox(height:22),
      FilledButton.icon(icon:const Icon(Icons.add),label:const Text('Create Custom Test'),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ExamSelectionScreen()))),
      const SizedBox(height:10),
      OutlinedButton.icon(icon:const Icon(Icons.history),label:Text('Test History (${HistoryStore.attempts.length})'),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const HistoryScreen()))),
      const SizedBox(height:24),
      ...exams.map((e)=>Card(child:ListTile(leading:CircleAvatar(child:Icon(e.icon)),title:Text(e.name,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(e.subtitle),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BuilderScreen(exam:e)))))
    ]));
}

class ExamSelectionScreen extends StatelessWidget {
  const ExamSelectionScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Select Exam')),
    body:ListView(padding:const EdgeInsets.all(16),children:exams.map((e)=>Card(child:ListTile(
      contentPadding:const EdgeInsets.all(16),leading:CircleAvatar(radius:28,child:Icon(e.icon)),
      title:Text(e.name,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(e.subtitle),
      trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BuilderScreen(exam:e)))))).toList()));
}

class BuilderScreen extends StatefulWidget {
  final Exam exam;
  const BuilderScreen({super.key,required this.exam});
  @override State<BuilderScreen> createState()=>_BuilderScreenState();
}
class _BuilderScreenState extends State<BuilderScreen> {
  final Map<String,List<String>> selected={};
  int count=20, minutes=30; String difficulty='Mixed';
  @override Widget build(BuildContext context){
    final total=selected.values.fold(0,(a,b)=>a+b.length);
    return Scaffold(appBar:AppBar(title:Text('${widget.exam.name} • Test Builder')),body:ListView(padding:const EdgeInsets.all(16),children:[
      const Text('Subjects & Chapters',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
      ...widget.exam.subjects.map((s){final cur=selected[s.name]??[];return Card(child:ExpansionTile(
        leading:Icon(s.icon),title:Text(s.name,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${cur.length}/${s.chapters.length} selected'),
        children:s.chapters.map((ch)=>CheckboxListTile(value:cur.contains(ch),title:Text(ch),controlAffinity:ListTileControlAffinity.leading,onChanged:(v)=>setState((){
          final l=[...(selected[s.name]??[])];v==true?l.add(ch):l.remove(ch);selected[s.name]=l;
        }))).toList()));}),
      const SizedBox(height:16),const Text('Question Count',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
      Card(child:Slider(value:count.toDouble(),min:5,max:100,divisions:19,label:'$count',onChanged:(v)=>setState(()=>count=v.round()))),
      Center(child:Text('$count questions')),
      const SizedBox(height:10),const Text('Time Limit',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
      Card(child:Slider(value:minutes.toDouble(),min:5,max:180,divisions:35,label:'$minutes min',onChanged:(v)=>setState(()=>minutes=v.round()))),
      Center(child:Text('$minutes minutes')),
      const SizedBox(height:10),const Text('Difficulty',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
      Wrap(spacing:8,children:['Easy','Medium','Hard','Mixed'].map((d)=>ChoiceChip(label:Text(d),selected:difficulty==d,onSelected:(_)=>setState(()=>difficulty=d))).toList()),
      const SizedBox(height:24),
      FilledButton.icon(icon:const Icon(Icons.play_arrow),label:Text(total==0?'Select chapters first':'Generate $count Question Test'),onPressed:total==0?null:(){
        final c=TestConfig(exam:widget.exam.name,chapters:Map.fromEntries(selected.entries.map((e)=>MapEntry(e.key,[...e.value]))),count:count,minutes:minutes,difficulty:difficulty);
        Navigator.push(context,MaterialPageRoute(builder:(_)=>TestScreen(config:c)));
      })
    ]));
  }
}

class TestScreen extends StatefulWidget {
  final TestConfig config;
  const TestScreen({super.key,required this.config});
  @override State<TestScreen> createState()=>_TestScreenState();
}
class _TestScreenState extends State<TestScreen> {
  late List<Question> questions; late List<int?> answers; late List<bool> review;
  Timer? timer; int current=0,remaining=0,elapsed=0; bool submitting=false;
  @override void initState(){super.initState();questions=generate(widget.config);answers=List.filled(questions.length,null);review=List.filled(questions.length,false);remaining=widget.config.minutes*60;
    timer=Timer.periodic(const Duration(seconds:1),(t){if(!mounted)return;if(remaining<=0){t.cancel();submit();}else{setState(()=>remaining--);elapsed++;}});
  }
  @override void dispose(){timer?.cancel();super.dispose();}
  String fmt(int s)=>'${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';
  Future<void> submit() async {
    if(submitting)return;setState(()=>submitting=true);timer?.cancel();
    final a=Attempt(id:DateTime.now().microsecondsSinceEpoch.toString(),config:widget.config,questions:questions,answers:[...answers],review:[...review],seconds:elapsed,date:DateTime.now());
    await HistoryStore.save(a);if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ResultScreen(attempt:a)));
  }
  Future<void> confirmSubmit() async {
    final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:const Text('Submit Test?'),content:Text('${answers.where((x)=>x!=null).length}/${questions.length} attempted. Review marked questions before submitting.'),actions:[
      TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Submit'))
    ]));if(ok==true)submit();
  }
  @override Widget build(BuildContext context){final q=questions[current];return Scaffold(
    appBar:AppBar(title:Text(widget.config.exam),actions:[Padding(padding:const EdgeInsets.symmetric(horizontal:14),child:Center(child:Text(fmt(remaining),style:TextStyle(fontWeight:FontWeight.w900,color:remaining<60?Colors.red:null))))]),
    body:Column(children:[
      LinearProgressIndicator(value:(current+1)/questions.length),
      Expanded(child:ListView(padding:const EdgeInsets.all(16),children:[
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Text('Question ${current+1} / ${questions.length}',style:const TextStyle(fontWeight:FontWeight.w800)),
          Wrap(children:[IconButton(tooltip:'Mark for Review',icon:Icon(review[current]?Icons.bookmark:Icons.bookmark_border),onPressed:()=>setState(()=>review[current]=!review[current])),
            IconButton(tooltip:'Question Palette',icon:const Icon(Icons.grid_view),onPressed:()=>showModalBottomSheet(context:context,builder:(_)=>Palette(total:questions.length,current:current,answers:answers,review:review,jump:(i){Navigator.pop(context);setState(()=>current=i);})))])
        ]),
        Chip(label:Text('${q.chapter} • ${q.difficulty}')),const SizedBox(height:12),
        Card(child:Padding(padding:const EdgeInsets.all(18),child:Text(q.text,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w700)))),
        const SizedBox(height:10),
        ...List.generate(q.options.length,(i)=>Card(child:RadioListTile<int>(value:i,groupValue:answers[current],title:Text(q.options[i]),onChanged:(v)=>setState(()=>answers[current]=v))))
      ])),
      SafeArea(child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
        OutlinedButton(onPressed:current==0?null:()=>setState(()=>current--),child:const Text('Previous')),
        const SizedBox(width:8),Expanded(child:FilledButton(onPressed:current==questions.length-1?confirmSubmit:()=>setState(()=>current++),child:Text(current==questions.length-1?'Submit Test':'Save & Next')))
      ]))
    ]));
  }
}

class Palette extends StatelessWidget {
  final int total,current; final List<int?> answers; final List<bool> review; final void Function(int) jump;
  const Palette({super.key,required this.total,required this.current,required this.answers,required this.review,required this.jump});
  @override Widget build(BuildContext context)=>SafeArea(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Question Palette',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:14),
    Wrap(spacing:9,runSpacing:9,children:List.generate(total,(i){
      final bg=i==current?Theme.of(context).colorScheme.primary:review[i]?Colors.orange:answers[i]!=null?Colors.green:null;
      return InkWell(onTap:()=>jump(i),child:CircleAvatar(backgroundColor:bg,child:Text('${i+1}',style:TextStyle(color:bg!=null?Colors.white:null))));
    }))
  ])));
}

class ResultScreen extends StatelessWidget {
  final Attempt attempt; const ResultScreen({super.key,required this.attempt});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Result')),body:ListView(padding:const EdgeInsets.all(20),children:[
    Card(child:Padding(padding:const EdgeInsets.all(24),child:Column(children:[
      Text('${attempt.score}',style:const TextStyle(fontSize:52,fontWeight:FontWeight.w900)),const Text('Score'),
      const SizedBox(height:18),Wrap(spacing:8,runSpacing:8,children:[Stat('Correct','${attempt.correct}'),Stat('Incorrect','${attempt.incorrect}'),Stat('Unattempted','${attempt.unattempted}'),Stat('Accuracy',attempt.attempted==0?'0%':'${(attempt.correct/attempt.attempted*100).round()}%')])
    ]))),
    const SizedBox(height:16),Text('${attempt.config.exam} • ${attempt.config.difficulty}',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
    Text('${attempt.questions.length} questions • ${attempt.config.minutes} min • ${attempt.seconds~/60} min used'),
    const SizedBox(height:22),
    FilledButton.icon(icon:const Icon(Icons.replay),label:const Text('Retake Test'),onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>TestScreen(config:attempt.config)))),
    OutlinedButton(onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const HistoryScreen())),child:const Text('Test History')),
    OutlinedButton(onPressed:()=>Navigator.popUntil(context,(r)=>r.isFirst),child:const Text('Back to Home'))
  ]));
}
class Stat extends StatelessWidget{final String a,b;const Stat(this.a,this.b,{super.key});@override Widget build(BuildContext c)=>Container(width:105,padding:const EdgeInsets.all(12),decoration:BoxDecoration(border:Border.all(color:Theme.of(c).dividerColor),borderRadius:BorderRadius.circular(12)),child:Column(children:[Text(b,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w800)),Text(a)]));}

class HistoryScreen extends StatefulWidget{const HistoryScreen({super.key});@override State<HistoryScreen> createState()=>_HistoryScreenState();}
class _HistoryScreenState extends State<HistoryScreen>{
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Test History')),body:HistoryStore.attempts.isEmpty?const Center(child:Text('No attempts yet.')):ListView.separated(
    padding:const EdgeInsets.all(16),itemCount:HistoryStore.attempts.length,separatorBuilder:(_,__)=>const SizedBox(height:8),
    itemBuilder:(_,i){final a=HistoryStore.attempts[i];return Card(child:ListTile(
      leading:CircleAvatar(child:Text('${a.score}')),title:Text('${a.config.exam} • ${a.config.difficulty}',style:const TextStyle(fontWeight:FontWeight.w800)),
      subtitle:Text('${a.correct}/${a.questions.length} correct • ${a.incorrect} wrong • ${a.unattempted} unattempted'),
      trailing:IconButton(icon:const Icon(Icons.replay),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>TestScreen(config:a.config)))),
      onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ResultScreen(attempt:a))));
    }));
  }
}
