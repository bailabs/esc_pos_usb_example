import 'package:esc_pos_usb_example/usb_device.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_usb/esc_pos_usb.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UsbDevice connected;
  List<UsbDevice> devices = [];
  PrinterUsbManager _printerUsbManager = PrinterUsbManager();

  Future<void> search() async {
    final List usbDevices = await _printerUsbManager.getDevices();
    setState(() {
      devices = [];
      usbDevices.forEach((device) {
        devices.add(UsbDevice(
          manufacturer: device['manufacturer'],
          product: device['product'],
          productid: int.parse(device['productid']),
          vendorid: int.parse(device['vendorid']),
        ));
      });
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Devices found'),
          content: Text('There are ${devices.length}'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  Widget _markConnected(UsbDevice device) {
    if (connected == null || (connected.productid != device.productid && connected.vendorid != device.vendorid)) {
      return Text('offline');
    }
    return Text('connected');
  }

  Future<void> printToConnected() async {
    final Ticket ticket = Ticket(PaperSize.mm80);
    ticket.text('Test Print');
    ticket.feed(2);
    ticket.cut();

    await _printerUsbManager.printTicket(ticket);
  }

  List<Widget> _buildList() {
    return devices.map((device) => InkWell(
      onTap: () async {
        await _printerUsbManager.connectDevice(
          device.vendorid,
          device.productid
        );
        setState(() {
          connected = device;
        });
      },
      onLongPress: () {
        printToConnected();
      },
      child: SizedBox(
        width: 360.0,
        height: 180.0,
        child: Card(
          child: Column(
            children: <Widget>[
              Text(
                device.manufacturer + " " + device.product,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              Text(device.vendorid.toString() + " " + device.productid.toString()),
              _markConnected(device),
            ],
          ),
        ),
      ),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ESC POS USB'),
            RaisedButton(
              child: Text('Search'),
              onPressed: search,
            ),
            SizedBox(height: 30.0),
            devices.length > 0
              ? Column(children: _buildList())
              : Text('No devices attached'),
          ],
        ),
      ),// T// his trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
