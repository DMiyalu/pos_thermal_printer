import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import './enum_printer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermal Printer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  void initBluetooth() {
    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          break;
      }
    });
    bluetooth.isConnected.then((isConnected) {
      setState(() {
        _connected = isConnected!;
      });
    });
  }

  void _getDevices() async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  void _connect() {
    if (_selectedDevice != null) {
      bluetooth.connect(_selectedDevice!);
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
  }

  void _printTest() async {
        ///image from File path
    String filename = 'yourlogo.png';
    ByteData bytesData = await rootBundle.load("images/visa.webp");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    ///image from Asset
    ByteData bytesAsset = await rootBundle.load("images/visa.webp");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    ///image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        // bluetooth.printNewLine();
        // bluetooth.printCustom("Facture n*023", 1, 1);
        // bluetooth.printCustom("-------------", 1, 3);
        // bluetooth.printCustom("Judha Moyibi", 1, 1);
        // bluetooth.printNewLine();
        // bluetooth.printNewLine();

        bluetooth.printNewLine();
        // bluetooth.printCustom("HEADER", Size.boldMedium.val, Align_POS.center.val);
        // bluetooth.printNewLine();
        // bluetooth.printImage(file.path); //path of your image/logo
        // bluetooth.printNewLine();
        // bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
        // bluetooth.printNewLine();
        // bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
        // bluetooth.printNewLine();
        // bluetooth.printLeftRight("LEFT", "RIGHT", Size.medium.val);
        // bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
        // bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
            // format:
            //     "%-15s %15s %n"); //15 is number off character from left or right
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
        bluetooth.printNewLine();
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val);
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val,
            format:
                "%-10s %10s %10s %n"); //10 is number off character from left center and right
        bluetooth.printNewLine();
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
            format: "%-8s %7s %7s %7s %n");
        bluetooth.printNewLine();
        bluetooth.printCustom("čĆžŽšŠ-H-ščđ", Size.bold.val, Align_POS.center.val,
            charset: "windows-1250");
        bluetooth.printLeftRight("Številka:", "18000001", Size.bold.val,
            charset: "windows-1250");
        bluetooth.printCustom("Body left", Size.bold.val, Align_POS.left.val);
        bluetooth.printCustom("Body right", Size.medium.val, Align_POS.right.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("Thank You", Size.bold.val, Align_POS.center.val);
        bluetooth.printNewLine();
        bluetooth.printQRcode(
            "Insert Your Own Text to Generate", 200, 200, Align_POS.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thermal Printer Demo'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: _getDevices,
            child: Text('Get Devices'),
          ),
          DropdownButton<BluetoothDevice>(
            items: _devices.map((device) {
              return DropdownMenuItem<BluetoothDevice>(
                value: device,
                child: Text(device.name!),
              );
            }).toList(),
            onChanged: (device) {
              setState(() {
                _selectedDevice = device!;
              });
            },
            value: _selectedDevice,
          ),
          ElevatedButton(
            onPressed: _connected ? _disconnect : _connect,
            child: Text(_connected ? 'Disconnect' : 'Connect'),
          ),
          ElevatedButton(
            onPressed: _printTest,
            child: Text('Print Test'),
          ),
        ],
      ),
    );
  }
}
