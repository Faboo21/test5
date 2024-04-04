import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NFC Reader",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Reader NFC"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? scannedNfcId;
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (scannedNfcId != null)
              Text('Scanned NFC ID: $scannedNfcId'),
            ElevatedButton(
              onPressed: isScanning ? null : _startNFCReading,
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(!isScanning ? Theme.of(context).colorScheme.inversePrimary : Colors.white10)),
              child: const Text('Start NFC Reading'),
            ),
            ElevatedButton(
              onPressed: isScanning ? _stopNFCReading : null,
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(isScanning ? Theme.of(context).colorScheme.inversePrimary : Colors.white10)),
              child: const Text('Stop NFC Reading'),
            ),
          ],
        ),
      ),
    );
  }

  void _startNFCReading() async {
    try {
      setState(() {
        isScanning = true;
      });

      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            List<int>? identifier = tag.data['nfca']?['identifier'];

            if (identifier != null) {
              String tagId = identifier.map((byte) => byte.toRadixString(16))
                  .join('');
              setState(() {
                scannedNfcId = tagId;
              });
            }
          },
        );
      } else {
        debugPrint('NFC not available.');
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }

  void _stopNFCReading() {
    setState(() {
      isScanning = false;
      scannedNfcId = null;
    });

    NfcManager.instance.stopSession();
  }
}
