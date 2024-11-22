import 'package:flutter/material.dart';
import 'package:speed_test_dart/classes/server.dart';
import 'package:speed_test_dart/speed_test_dart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpeedTestDart tester = SpeedTestDart();
  List<Server> bestServersList = [];

  double downloadRate = 0;
  double uploadRate = 0;
  double _speedValue = 0;

  bool readyToTest = false;
  bool loadingDownload = false;
  bool loadingUpload = false;

  setBestServers() async {
    final settings = await tester.getSettings();
    final servers = settings.servers;

    final _bestServersList = await tester.getBestServers(
      servers: servers,
    );

    setState(() {
      bestServersList = _bestServersList;
      readyToTest = true;
    });
  }

  // Future<void> setBestServers() async {
  //   try {
  //     // Get the raw response from the server (before parsing as XML)
  //     final settings = await tester.getSettings();
  //     print("Raw response: ${settings.toString()}");
  //
  //     // Manually check and handle the response (assuming it's a raw XML string or similar format)
  //     var document = xml.XmlDocument.parse(settings.toString());
  //
  //     // Extract server elements (update tag names as per actual XML structure)
  //     final List<xml.XmlElement> serverElements =
  //         document.findAllElements('server').toList();
  //
  //     // Convert XmlElement list to List<Server>
  //     List<Server> servers = serverElements.map((xmlElement) {
  //       // Extract necessary data from the XML element to create a Server object
  //       String name = xmlElement.getElement('name')?.text ?? '';
  //       String country = xmlElement.getElement('country')?.text ?? '';
  //       String url = xmlElement.getElement('url')?.text ?? '';
  //
  //       // Create Server object using extracted data
  //       return Server(name: name, country: country, url: url);
  //     }).toList();
  //
  //     print("Servers found: $servers");
  //
  //     // Get the best servers from the parsed list
  //     final _bestServersList = await tester.getBestServers(servers: servers);
  //
  //     // Update the state after successfully fetching the best servers
  //     setState(() {
  //       bestServersList = _bestServersList;
  //       readyToTest = true;
  //     });
  //   } catch (e) {
  //     print("Error during server setup or XML parsing: $e");
  //   }
  // }

  _testDownloadSpeed() async {
    setState(() {
      loadingDownload = true;
    });
    final _downloadRate =
        await tester.testDownloadSpeed(servers: bestServersList);
    setState(() {
      downloadRate = _downloadRate;
      _speedValue = downloadRate;
      loadingDownload = false;
    });
  }

  _testUploadSpeed() async {
    setState(() {
      loadingUpload = true;
    });

    final _uploadRate = await tester.testUploadSpeed(servers: bestServersList);

    setState(() {
      uploadRate = _uploadRate;
      _speedValue = uploadRate;
      loadingUpload = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBestServers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gfg Internet Speed Tester'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SfRadialGauge(
                  enableLoadingAnimation: true,
                  animationDuration: 4500,
                  axes: <RadialAxis>[
                    RadialAxis(minimum: 0, maximum: 60, ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0, endValue: 20, color: Colors.green),
                      GaugeRange(
                          startValue: 20, endValue: 40, color: Colors.orange),
                      GaugeRange(
                          startValue: 40, endValue: 60, color: Colors.red)
                    ], pointers: <GaugePointer>[
                      NeedlePointer(value: _speedValue)
                    ], annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Text("${_speedValue.toStringAsFixed(2)} Mb/s",
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold)),
                          angle: 90,
                          positionFactor: 0.6)
                    ])
                  ]),
              const Text(
                'Test Upload speed:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (loadingUpload)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Testing upload speed...'),
                  ],
                )
              else
                Text('Upload rate ${uploadRate.toStringAsFixed(2)} Mb/s'),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: loadingUpload
                    ? null
                    : () async {
                        if (!readyToTest || bestServersList.isEmpty) return;
                        await _testUploadSpeed();
                      },
                child: const Text('Start'),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Test Download Speed:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (loadingDownload)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Testing download speed...'),
                  ],
                )
              else
                Text('Download rate  ${downloadRate.toStringAsFixed(2)} Mb/s'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loadingDownload
                    ? null
                    : () async {
                        if (!readyToTest || bestServersList.isEmpty) return;
                        await _testDownloadSpeed();
                      },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
