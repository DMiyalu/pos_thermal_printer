import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';

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

  void _printTest() {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        bluetooth.printNewLine();
        bluetooth.printCustom("Facture n*023", 1, 1);
        bluetooth.printCustom("-------------", 1, 3);
        bluetooth.printCustom("Stynos Moyibi", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
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
