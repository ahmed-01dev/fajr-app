import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kBg = Color(0xFF0D1B2A);
const kCard = Color(0xFF16263A);
const kGreen = Color(0xFF0E9F6E);
const kGold = Color(0xFFD4AF37);
const kText = Color(0xFFF8F5EF);

const verses = [
  {'text': 'وَقُرْآنَ الْفَجْرِ ۖ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا', 'ref': 'الإسراء ٧٨'},
  {'text': 'تَتَجَافَىٰ جُنُوبُهُمْ عَنِ الْمَضَاجِعِ يَدْعُونَ رَبَّهُمْ خَوْفًا وَطَمَعًا', 'ref': 'السجدة ١٦'},
  {'text': 'كَانُوا قَلِيلًا مِّنَ اللَّيْلِ مَا يَهْجَعُونَ', 'ref': 'الذاريات ١٧'},
  {'text': 'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ', 'ref': 'المائدة ٢'},
];

const ranks = [
  ['🌱', 'المبتدئ', 0],
  ['🌅', 'صاحي الفجر', 100],
  ['⏰', 'الموقِظ', 300],
  ['🤝', 'صديق الفجر', 600],
  ['🛡️', 'حارس الفجر', 1000],
  ['⚔️', 'قائد الفجر', 1600],
  ['👑', 'فاتح الفجر — الكونكر', 2500],
];

const arabMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const arabDays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

void main() => runApp(const FajrApp());

class FajrApp extends StatelessWidget {
  const FajrApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فَجْر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kGreen, secondary: kGold, surface: kCard),
      ),
      builder: (c, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const Root(),
    );
  }
}

String dstr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool? onboarded;
  @override
  void initState() {
    super.initState();
    () async {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => onboarded = p.getBool('onboarded') ?? false);
    }();
  }

@override
  Widget build(BuildContext context) {
    if (onboarded == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kGreen)));
    }
    return onboarded! ? const MainShell() : Onboarding(onDone: () => setState(() => onboarded = true));
  }
}

class Onboarding extends StatefulWidget {
  final VoidCallback onDone;
  const Onboarding({super.key, required this.onDone});
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final ctrl = PageController();
  final nameCtrl = TextEditingController();
  int page = 0;

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: ctrl,
        onPageChanged: (i) => setState(() => page = i),
        children: [
          slide('🌙', 'وَالْفَجْرِ • وَلَيَالٍ عَشْرٍ', 'الفجر أجمل لما نصحّي بعض', isVerse: true),
          slide('🤝', 'مش لوحدك', 'انضم لمجموعة تساعدك وتساعد غيرك'),
          Scaffold(
            backgroundColor: kBg,
            body: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✅', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('صحيت؟ ساعد غيرك', style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 8),
                  Text('بضغطة واحدة تبدأ رحلة إيقاظ أصحابك', style: GoogleFonts.cairo(color: kText.withOpacity(.7))),
                  const SizedBox(height: 28),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.cairo(color: kText),
                    decoration: InputDecoration(
                      hintText: 'اكتب اسمك',
                      hintStyle: GoogleFonts.cairo(color: kText.withOpacity(.5)),
                      filled: true, fillColor: kCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        final p = await SharedPreferences.getInstance();
                        final n = nameCtrl.text.trim();
                        if (n.isNotEmpty) await p.setString('name', n);
                        await p.setBool('onboarded', true);
                        widget.onDone();
                      },
                      child: Text('ابدأ الآن 🚀', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget slide(String icon, String title, String sub, {bool isVerse = false}) {
    return Scaffold(
      backgroundColor: kBg,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            isVerse
                ? Text(title, textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 30, color: kGold))
                : Text(title, style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 12),
            Text(sub, textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 16, color: kText.withOpacity(.7))),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10, height: 10,
                decoration: BoxDecoration(color: i == page ? kGreen : kCard, shape: BoxShape.circle),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final groupCtrl = TextEditingController();
  final joinCtrl = TextEditingController();

int tab = 0;
  String name = '';
  int xp = 0, streak = 0, wakeCount = 0, helpCount = 0;
  String lastWake = '';
  List<Map<String, dynamic>> logs = [];
  List<int> azkar = [0, 0, 0];
  List<int> helpers = [0, 0, 0];
  String? groupName, groupCode;
  Timer? timer;
  Duration left = const Duration();

final demoNames = ['محمد', 'عبد الله', 'أمينة'];

@override
  void initState() {
    super.initState();
    () async {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        name = p.getString('name') ?? 'صديق الفجر';
        xp = p.getInt('xp') ?? 0;
        streak = p.getInt('streak') ?? 0;
        wakeCount = p.getInt('wakeCount') ?? 0;
        helpCount = p.getInt('helpCount') ?? 0;
        lastWake = p.getString('lastWake') ?? '';
        groupName = p.getString('group');
        groupCode = p.getString('code');
        try {
          logs = (jsonDecode(p.getString('logs') ?? '[]') as List).cast<Map<String, dynamic>>();
          azkar = (jsonDecode(p.getString('azkar') ?? '[0,0,0]') as List).cast<int>();
          helpers = (jsonDecode(p.getString('helpers') ?? '[0,0,0]') as List).cast<int>();
        } catch (_) {}
      });
    }();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => left = nextFajr().difference(DateTime.now()));
    });
  }

@override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

DateTime nextFajr() {
    final n = DateTime.now();
    var f = DateTime(n.year, n.month, n.day, 5, 12);
    if (f.isBefore(n)) f = f.add(const Duration(days: 1));
    return f;
  }

Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('xp', xp);
    await p.setInt('streak', streak);
    await p.setInt('wakeCount', wakeCount);
    await p.setInt('helpCount', helpCount);
    await p.setString('lastWake', lastWake);
    await p.setString('logs', jsonEncode(logs));
    await p.setString('azkar', jsonEncode(azkar));
    await p.setString('helpers', jsonEncode(helpers));
  }

void snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.cairo()),
      backgroundColor: kCard,
      behavior: SnackBarBehavior.floating,
    ));
  }

void addLog(String kind, String text) {
    logs.insert(0, {'d': dstr(DateTime.now()), 'k': kind, 't': text});
  }

int get rankIndex {
    int i = 0;
    for (int j = 0; j < ranks.length; j++) {
      if (xp >= ranks[j][2] as int) i = j;
    }
    return i;
  }

void gainXp(int n) {
    final before = rankIndex;
    xp += n;
    final after = rankIndex;
    if (after > before) {
      Future.delayed(Duration.zero, () {
        snack('🎉 ترقية! وصلت لرتبة ${ranks[after][1]} ${ranks[after][0]}');
      });
    }
  }

void wakeUp() async {
    final today = dstr(DateTime.now());
    if (lastWake == today) {
      snack('أنت صحيت خلاص النهارده 😄 جزاك الله خيرًا');
      return;
    }
    final yesterday = dstr(DateTime.now().subtract(const Duration(days: 1)));
    streak = (lastWake == yesterday) ? streak + 1 : 1;
    lastWake = today;
    wakeCount++;
    final bonus = streak >= 30 ? 8 : (streak >= 7 ? 4 : 0);
    gainXp(10 + bonus);
    addLog('wake', 'صحيت للفجر ✅ (+${10 + bonus} نقطة) — سلسلة $streak يوم 🔥');
    await save();
    setState(() {});
    showModalBottomSheet(
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🌅', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: kGold), borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text('بَشِّرِ الْمَشَّائِينَ فِي الظُّلَمِ إِلَى الْمَسَاجِدِ بِالنُّورِ التَّامِّ يَوْمَ الْقِيَامَةِ',
                  textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 20, color: kGold)),
              const SizedBox(height: 6),
              Text('رواه أبو داود والترمذي', style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.6))),
            ]),
          ),
          const SizedBox(height: 12),
          Text('جزاك الله خيرًا! ابدأ يومك بنية 💚', style: GoogleFonts.cairo(color: kText)),
        ]),
      ),
    );
  }

void callHelper(int i) async {
    if (helpers[i] == 2) return;
    if (helpers[i] == 0) {
      helpers[i] = 1;
      gainXp(5);
      addLog('help', 'اتصلت لإيقاظ ${demoNames[i]} 📞 (+5)');
      await save();
      setState(() {});
      snack('جاري الاتصال بـ${demoNames[i]}... 📞');
    } else {
      helpers[i] = 2;
      helpCount++;
      gainXp(25);
      addLog('help', '${demoNames[i]} استيقظ بفضل الله 🌅 (+25)');
      await save();
      setState(() {});
      snack('جزاك الله خيرًا! ${demoNames[i]} استيقظ 🌅 (+25 نقطة)');
    }
  }

String two(int n) => n.toString().padLeft(2, '0');

@override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final verse = verses[now.day % verses.length];
    final tabs = [homeTab(verse), boardTab(), azkarTab(), logTab(), meTab()];
    return Scaffold(
      body: tabs[tab],
      bottomNavigationBar: NavigationBar(
        backgroundColor: kCard,
        indicatorColor: kGreen.withOpacity(.25),
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_twilight_outlined), selectedIcon: Icon(Icons.wb_twilight), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'المتصدرون'),
          NavigationDestination(icon: Icon(Icons.fingerprint), label: 'الأذكار'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'سجلي'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

Widget card({required Widget child, Color? color, Border? border}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color ?? kCard, borderRadius: BorderRadius.circular(14), border: border),
    child: child,
  );

Widget homeTab(Map<String, String> verse) {
    final now = DateTime.now();
    final dateStr = '${arabDays[now.weekday - 1]} ${now.day} ${arabMonths[now.month - 1]} ${now.year}';
    return ListView(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1040), Color(0xFF3D2B56), kBg],
        )),
        child: Column(children: [
          const Text('🌙', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('أهلاً $name 👋', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: kText)),
          Text(dateStr, style: GoogleFonts.cairo(color: kText.withOpacity(.6))),
          const SizedBox(height: 12),
          Text('نصحّي بعض على الخير', style: GoogleFonts.cairo(color: kGold, fontSize: 13)),
        ]),
      ),
      card(child: Column(children: [
        Text(verse['text']!, textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 21, color: kGold)),
        const SizedBox(height: 6),
        Text(verse['ref']!, style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.5))),
      ])),
      card(child: Column(children: [
        Text('الوقت المتبقي للفجر (مدينة تجريبية — القاهرة)', style: GoogleFonts.cairo(color: kText.withOpacity(.7), fontSize: 13)),
        const SizedBox(height: 6),
        Text('${two(left.inHours)}:${two(left.inMinutes % 60)}:${two(left.inSeconds % 60)}',
            style: GoogleFonts.cairo(fontSize: 42, fontWeight: FontWeight.bold, color: kGreen)),
      ])),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 64,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: wakeUp,
            child: Text('أنا صحيت 🌅', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      card(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        stat('🔥', '$streak', 'سلسلة'),
        stat('⭐', '$xp', 'نقاط'),
        stat('🌅', '$wakeCount', 'صحوات'),
        stat('🤝', '$helpCount', 'ساعدت'),
      ])),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('ساعد حد يصحى 🤝', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
      ),
      ...List.generate(3, (i) => card(child: Row(children: [
        CircleAvatar(backgroundColor: kGreen.withOpacity(.2), child: Text(demoNames[i][0], style: GoogleFonts.cairo(color: kGreen))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(demoNames[i], style: GoogleFonts.cairo(color: kText, fontWeight: FontWeight.bold)),
          Text(['قيد الانتظار', 'تم الاتصال ✅', 'استيقظ الحمد لله 🌅'][helpers[i]],
              style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.6))),
        ])),
        helpers[i] < 2
            ? FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kGreen),
                onPressed: () => callHelper(i),
                child: Text(helpers[i] == 0 ? 'اتصل 📞' : 'استيقظ ✅', style: GoogleFonts.cairo()),
              )
            : const Icon(Icons.check_circle, color: kGreen),
      ]))),
      const SizedBox(height: 20),
    ]);
  }

Widget stat(String icon, String val, String label) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 22)),
    Text(val, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
    Text(label, style: GoogleFonts.cairo(fontSize: 11, color: kText.withOpacity(.5))),
  ]);

Widget boardTab() {
    final list = [
      ['خالد', 1250], ['مريم', 980], ['يوسف', 860], ['سارة', 720], ['عمر', 540], ['آية', 410], ['زياد', 260],
      ['أنت', xp],
    ];
    list.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
    const medals = ['🥇', '🥈', '🥉'];
    return ListView(children: [
      const SizedBox(height: 50),
      Text('وَفِي ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَ', textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 20, color: kGold)),
      Text('المطففين ٢٦', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 11, color: kText.withOpacity(.5))),
      const SizedBox(height: 10),
      Text('🏆 لوحة المتصدرين (تجريبي)', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
      const SizedBox(height: 10),
      ...List.generate(list.length, (i) => card(
        border: list[i][0] == 'أنت' ? Border.all(color: kGreen) : null,
        child: Row(children: [
          Text(i < 3 ? medals[i] : '${i + 1}', style: GoogleFonts.cairo(fontSize: 18, color: kGold)),
          const SizedBox(width: 12),
          Expanded(child: Text(list[i][0] == 'أنت' ? '$name (أنت) 👑' : '${list[i][0]}', style: GoogleFonts.cairo(color: kText))),
          Text('${list[i][1]} ⭐', style: GoogleFonts.cairo(color: kGreen)),
        ]),
      )),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text('المنافسة هنا للتحفيز على الخير لا للفخر 💚', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.5))),
      ),
    ]);
  }

Widget azkarTab() {
    const labels = ['سبحان الله وبحمده', 'أستغفر الله', 'اللهم صل على محمد'];
    return ListView(children: [
      const SizedBox(height: 50),
      Text('📿 المسبحة الرقمية', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
      const SizedBox(height: 10),
      ...List.generate(3, (i) => card(child: Column(children: [
        Text(labels[i], style: GoogleFonts.cairo(fontSize: 18, color: kGold)),
        const SizedBox(height: 8),
        Text('${azkar[i]} / 100', style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kGreen),
            onPressed: () async {
              setState(() => azkar[i]++);
              if (azkar[i] == 100) snack('خلصت الذكر 💚 جزاك الله خيرًا');
              await save();
            },
            child: Text('+1', style: GoogleFonts.cairo(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async { setState(() => azkar[i] = 0); await save(); },
            child: Text('تصفير', style: GoogleFonts.cairo(color: kText.withOpacity(.6))),
          ),
        ]),
      ]))),
    ]);
  }

Widget logTab() {
    final wakeDays = logs.where((l) => l['k'] == 'wake').map((l) => l['d']).toSet();
    return ListView(children: [
      const SizedBox(height: 50),
      Text('📋 سجل النشاط', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
      const SizedBox(height: 12),
      card(child: Column(children: [
        Text('آخر ٧ أيام', style: GoogleFonts.cairo(color: kText.withOpacity(.6), fontSize: 13)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(7, (i) {
          final d = DateTime.now().subtract(Duration(days: 6 - i));
          final woke = wakeDays.contains(dstr(d));
          return Column(children: [
            Container(width: 22, height: 22, decoration: BoxDecoration(
              color: woke ? kGreen : kCard,
              border: Border.all(color: woke ? kGreen : kText.withOpacity(.2)),
              shape: BoxShape.circle,
            )),
            const SizedBox(height: 4),
            Text('${d.day}', style: GoogleFonts.cairo(fontSize: 10, color: kText.withOpacity(.5))),
          ]);
        })),
      ])),
      if (logs.isEmpty)
        Padding(padding: const EdgeInsets.all(30), child: Text('لسه مفيش نشاط — ابدأ أول صحوة 🌅', textAlign: TextAlign.center, style: GoogleFonts.cairo(color: kText.withOpacity(.6))))
      else
        ...logs.map((l) => card(child: Row(children: [
          const Icon(Icons.circle, size: 10, color: kGreen),
          const SizedBox(width: 10),
          Expanded(child: Text('${l['t']}', style: GoogleFonts.cairo(color: kText, fontSize: 14))),
          Text('${l['d']}', style: GoogleFonts.cairo(fontSize: 11, color: kText.withOpacity(.4))),
        ]))),
    ]);
  }

Widget meTab() {
    final ri = rankIndex;
    final next = ri < ranks.length - 1 ? ranks[ri + 1] : null;
    final progress = next != null
        ? ((xp - (ranks[ri][2] as int)) / ((next[2] as int) - (ranks[ri][2] as int))).clamp(0.0, 1.0).toDouble()
        : 1.0;
    final achievements = [
      ['أول صحوة 🌅', wakeCount >= 1],
      ['سلسلة أسبوع 🔥', streak >= 7],
      ['أيقظت 10 أشخاص 🤝', helpCount >= 10],
      ['صاحي الشهر 🏅', streak >= 30],
      ['الكونكر 👑', xp >= 2500],
    ];
    return ListView(children: [
      const SizedBox(height: 50),
      card(
        border: ri == ranks.length - 1 ? Border.all(color: kGold, width: 2) : null,
        child: Column(children: [
          Text('${ranks[ri][0]}', style: TextStyle(fontSize: ri == ranks.length - 1 ? 48 : 36)),
          const SizedBox(height: 6),
          Text('${ranks[ri][1]}', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: ri == ranks.length - 1 ? kGold : kText)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, color: kGreen, backgroundColor: kBg, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 8),
          Text(next != null ? 'باقي ${(next[2] as int) - xp} نقطة لرتبة ${next[1]} ${next[0]}' : 'وصلت لأعلى رتبة 👑 مبروك!',
              style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.7))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('🎖️ الإنجازات', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
      ),
      ...achievements.map((a) => card(child: Row(children: [
        Icon(a[1] == true ? Icons.emoji_events : Icons.lock, color: a[1] == true ? kGold : kText.withOpacity(.3)),
        const SizedBox(width: 12),
        Text('${a[0]}', style: GoogleFonts.cairo(color: a[1] == true ? kText : kText.withOpacity(.4))),
      ]))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('👥 مجموعتي', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
      ),
      card(child: groupName == null
          ? Column(children: [
              TextField(controller: groupCtrl, style: GoogleFonts.cairo(color: kText),
                decoration: InputDecoration(hintText: 'اسم المجموعة', hintStyle: GoogleFonts.cairo(color: kText.withOpacity(.5)),
                  filled: true, fillColor: kBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kGreen),
                onPressed: () async {
                  final g = groupCtrl.text.trim();
                  if (g.isEmpty) return;
                  final rand = Random();
                  final code = List.generate(6, (_) => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[rand.nextInt(32)]).join();
                  final p = await SharedPreferences.getInstance();
                  await p.setString('group', g);
                  await p.setString('code', code);
                  if (mounted) setState(() { groupName = g; groupCode = code; });
                },
                child: Text('إنشاء مجموعة', style: GoogleFonts.cairo()),
              ),
              const SizedBox(height: 8),
              TextField(controller: joinCtrl, style: GoogleFonts.cairo(color: kText),
                decoration: InputDecoration(hintText: 'كود دعوة للانضمام', hintStyle: GoogleFonts.cairo(color: kText.withOpacity(.5)),
                  filled: true, fillColor: kBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
              TextButton(
                onPressed: () {
                  if (joinCtrl.text.trim().length == 6) {
                    snack('انضممت للمجموعة (تجريبي) ✅');
                  } else {
                    snack('الكود لازم يكون 6 حروف/أرقام');
                  }
                },
                child: Text('انضمام بكود', style: GoogleFonts.cairo(color: kGreen)),
              ),
            ])
          : Column(children: [
              Text(groupName!, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: kGold), borderRadius: BorderRadius.circular(14)),
                child: Text('كود الدعوة: $groupCode', style: GoogleFonts.cairo(color: kGold, fontSize: 18, letterSpacing: 3)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final p = await SharedPreferences.getInstance();
                  await p.remove('group');
                  await p.remove('code');
                  if (mounted) setState(() { groupName = null; groupCode = null; });
                },
                child: Text('مغادرة المجموعة', style: GoogleFonts.cairo(color: kText.withOpacity(.5))),
              ),
            ])),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
              backgroundColor: kCard,
              title: Text('حذف كل البيانات؟', style: GoogleFonts.cairo(color: kText)),
              content: Text('هيتمسح كل حاجة: النقاط، السلسلة، السجل، المجموعة.', style: GoogleFonts.cairo(color: kText.withOpacity(.7))),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء', style: GoogleFonts.cairo())),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('احذف', style: GoogleFonts.cairo()),
                ),
              ],
            ));
            if (ok == true) {
              final p = await SharedPreferences.getInstance();
              await p.clear();
              if (mounted) {
                setState(() { xp = 0; streak = 0; wakeCount = 0; helpCount = 0; lastWake = ''; logs = []; azkar = [0, 0, 0]; helpers = [0, 0, 0]; groupName = null; groupCode = null; });
                snack('تم حذف كل البيانات ✅');
              }
            }
          },
          child: Text('🗑️ حذف كل البيانات', style: GoogleFonts.cairo(color: Colors.red)),
        ),
      ),
      const SizedBox(height: 20),
    ]);
  }
}
