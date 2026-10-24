import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const red = Color(0xFFD62828), green = Color(0xFF1B7A3E);
const h1 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

void main() => runApp(const App());

Future<void> open(String url) async {
  try { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); } catch (_) {}
}
void call(String n) => open('tel:$n');

Position? pos;
Future<Position?> locate() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return null;
    return pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)));
  } catch (_) { return null; }
}
String mapLink() => 'https://www.google.com/maps?q=${pos!.latitude.toStringAsFixed(6)},${pos!.longitude.toStringAsFixed(6)}';
String message() => '🚨 ALERTE Burkina SOS : j’ai besoin d’aide ! ' +
    (pos != null ? 'Ma position : ${mapLink()}' : 'Ma position n’est pas disponible, appelez-moi vite.');

Future<List<String>> contacts() async =>
    List.of((await SharedPreferences.getInstance()).getStringList('contacts') ?? []);

Future<void> alertNear(BuildContext c) async {
  final l = await contacts();
  if (l.isEmpty) {
    if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Ajoutez d’abord un contact de confiance (onglet Proches).')));
    return;
  }
  await locate();
  final nums = l.map((e) => e.split('|')[1].replaceAll(' ', '')).join(',');
  await open('sms:$nums?body=${Uri.encodeComponent(message())}');
}

void sos(BuildContext c) {
  showModalBottomSheet(context: c, builder: (_) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🚨 Confirmer l’alerte SOS ?', style: h1),
      const SizedBox(height: 12),
      for (final e in [['Police', '17'], ['Gendarmerie', '16'], ['Pompiers', '18'], ['SAMU', '15']])
        Padding(padding: const EdgeInsets.only(bottom: 8), child: SizedBox(width: double.infinity,
          child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: red), icon: const Icon(Icons.call),
            label: Text('${e[0]} ${e[1]}'), onPressed: () => call(e[1])))),
      SizedBox(width: double.infinity, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: green),
        icon: const Icon(Icons.groups), label: const Text('Alerter mes proches'),
        onPressed: () { Navigator.pop(c); alertNear(c); })),
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
    ]),
  ));
  locate();
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
        title: 'Burkina SOS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: red), useMaterial3: true),
        darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.dark), useMaterial3: true),
        home: const Splash(),
      );
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}
class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()));
    });
  }
  @override
  Widget build(BuildContext c) => const Scaffold(backgroundColor: red, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star, size: 72, color: Color(0xFFF5C400)),
        Text('Burkina SOS', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
        Padding(padding: EdgeInsets.all(8), child: Text('Un seul geste, toute une nation à votre secours !', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
        SizedBox(height: 24),
        CircularProgressIndicator(color: Colors.white),
      ])));
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}
class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext c) => Scaffold(
        body: SafeArea(child: IndexedStack(index: i, children: const [HomeTab(), ServicesTab(), PositionTab(), NearTab(), MoreTab()])),
        bottomNavigationBar: NavigationBar(selectedIndex: i, onDestinationSelected: (v) => setState(() => i = v), destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.local_police), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.location_on), label: 'Position'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Proches'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Plus'),
        ]),
      );
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext c) => Center(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        const Text('Burkina SOS', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: red)),
        const Text('Un seul geste, toute une nation à votre secours !', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Text('Bienvenue !', style: h1),
        const Text('Accédez rapidement aux secours et restez en sécurité.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => sos(c),
          child: Container(
            width: 200, height: 200, alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: red, boxShadow: [BoxShadow(color: Color(0x66D62828), blurRadius: 30, spreadRadius: 6)]),
            child: const Column(mainAxisSize: MainAxisSize.min, children: [
              Text('SOS', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w800)),
              Text('Appel d’urgence', style: TextStyle(color: Colors.white)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Appuyez, puis confirmez pour éviter les faux déclenchements.', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: () => alertNear(c), icon: const Icon(Icons.groups), label: const Text('Alerter mes proches')),
      ])));
}

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});
  @override
  Widget build(BuildContext c) {
    final s = [['Police nationale', '17', 0xFF1456C8], ['Gendarmerie nationale', '16', 0xFF1B7A3E], ['Sapeurs-pompiers', '18', 0xFFD62828], ['Urgences médicales (SAMU)', '15', 0xFFC2185B]];
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Services d’urgence', style: h1),
      const SizedBox(height: 12),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
        for (final e in s)
          InkWell(
            onTap: () => call(e[1] as String),
            child: Container(
              decoration: BoxDecoration(color: Color(e[2] as int), borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(e[0] as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                Text(e[1] as String, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                const Icon(Icons.call, color: Colors.white),
              ]),
            ),
          ),
      ]),
      const SizedBox(height: 12),
      Card(child: ListTile(
        leading: const Icon(Icons.shield),
        title: const Text('CNVA — Centre National de Veille et d’Alerte'),
        subtitle: const Text('Informations fiables, signalements'),
        trailing: const Text('10-10', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        onTap: () => call('1010'),
      )),
    ]);
  }
}

class PositionTab extends StatefulWidget {
  const PositionTab({super.key});
  @override
  State<PositionTab> createState() => _PositionTabState();
}
class _PositionTabState extends State<PositionTab> {
  String info = 'Recherche de votre position…';
  @override
  void initState() { super.initState(); refresh(); }
  Future<void> refresh() async {
    setState(() => info = 'Recherche de votre position…');
    final p = await locate();
    if (!mounted) return;
    setState(() => info = p == null
        ? 'Position indisponible. Autorisez la localisation et activez le GPS.'
        : 'Lat : ${p.latitude.toStringAsFixed(4)}\nLong : ${p.longitude.toStringAsFixed(4)}\nPrécision : ${p.accuracy.round()} m');
  }
  @override
  Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Ma position', style: h1),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(info))),
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: red), icon: const Icon(Icons.share), label: const Text('Partager ma position'),
            onPressed: () { if (pos != null) Share.share(message()); }),
        OutlinedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Actualiser'), onPressed: refresh),
        OutlinedButton.icon(icon: const Icon(Icons.map), label: const Text('Voir sur Google Maps'), onPressed: () { if (pos != null) open(mapLink()); }),
        OutlinedButton.icon(icon: const Icon(Icons.groups), label: const Text('Envoyer à mes proches'), onPressed: () => alertNear(c)),
      ]);
}

class NearTab extends StatefulWidget {
  const NearTab({super.key});
  @override
  State<NearTab> createState() => _NearTabState();
}
class _NearTabState extends State<NearTab> {
  List<String> l = [];
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async { final x = await contacts(); if (mounted) setState(() => l = x); }
  Future<void> save() async => (await SharedPreferences.getInstance()).setStringList('contacts', l);
  Future<void> add() async {
    final n = TextEditingController(), p = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(
      title: const Text('Nouveau contact'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: 'Nom')),
        TextField(controller: p, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Ajouter')),
      ],
    ));
    if (ok == true && n.text.trim().isNotEmpty && p.text.replaceAll(RegExp(r'\D'), '').length >= 8) {
      setState(() => l.add('${n.text.trim()}|${p.text.trim()}'));
      await save();
    }
  }
  @override
  Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Alerte au proche', style: h1),
        const SizedBox(height: 8),
        const Text('En cas d’urgence, alertez vos proches en un seul clic. Votre position et un message d’assistance leur seront envoyés.'),
        const SizedBox(height: 12),
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: red), icon: const Icon(Icons.share), label: const Text('Alerter mes proches'), onPressed: () => alertNear(c)),
        const SizedBox(height: 16),
        const Text('Mes contacts de confiance', style: TextStyle(fontWeight: FontWeight.bold)),
        if (l.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Aucun contact pour le moment.')),
        for (var k = 0; k < l.length; k++)
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(l[k].split('|')[0]),
            subtitle: Text(l[k].split('|')[1]),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.call), onPressed: () => call(l[k].split('|')[1].replaceAll(' ', ''))),
              IconButton(icon: const Icon(Icons.delete), onPressed: () async { setState(() => l.removeAt(k)); await save(); }),
            ]),
          ),
        OutlinedButton.icon(icon: const Icon(Icons.add), label: const Text('Ajouter un contact'), onPressed: add),
      ]);
}

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});
  @override
  Widget build(BuildContext c) {
    const items = [
      ['Avis de recherche (CNVA)', 'Une information sur une personne recherchée ? Contactez le CNVA au 10-10 ou les forces de l’ordre. Ne vous mettez jamais en danger.'],
      ['Contacts d’urgence', 'Police : 17\nGendarmerie : 16\nSapeurs-pompiers : 18\nSAMU : 15\nCNVA : 10-10'],
      ['Aide & Conseils', 'Restez calme, donnez votre lieu précis, ne raccrochez pas avant d’y être invité et activez le GPS.'],
      ['À propos', 'Burkina SOS — Un seul geste, toute une nation à votre secours ! Version 1. Ne remplace pas les services officiels.'],
      ['Confidentialité', 'Vos contacts restent sur votre appareil. Votre position n’est partagée que lorsque vous le décidez.'],
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Plus', style: h1),
      for (final e in items)
        ExpansionTile(title: Text(e[0]), children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(e[1]))]),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(16)),
          child: const Text('Ensemble, restons vigilants !', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ]);
  }
}
