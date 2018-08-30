import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_amap_location/flutter_amap_location.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _Data {
  final AMapLocation location;
  final DateTime timestamp;

  _Data(this.location, this.timestamp);
}

class _MyAppState extends State<MyApp> {
  final _data = <_Data>[];
  final _option = new AMapLocationClientOption();
  var _running = false;

  StreamSubscription _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscription?.cancel();
    _subscription =
        FlutterAMapLocation.get().onLocationChanged.listen(_onLocationChanged);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: new ListView.builder(
                itemCount: _data.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (BuildContext context, int index) {
                  return new _LocationWidget(
                    data: _data[index],
                  );
                },
              ),
            ),
            new Wrap(
              children: <Widget>[
                // TODO options
              ],
            ),
            new Wrap(
              children: <Widget>[
                new FlatButton(
                  onPressed: _running ? null : _start,
                  child: new Text('Start'),
                ),
                new FlatButton(
                  onPressed: _running ? _stop : null,
                  child: new Text('Stop'),
                ),
                new FlatButton(
                  onPressed: () {
                    _data.clear();
                    setState(() {});
                  },
                  child: new Text('Clear'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onLocationChanged(AMapLocation location) {
    _data.add(new _Data(location, new DateTime.now()));
    setState(() {});
  }

  Future<void> _start() async {
    await _stop();
    await FlutterAMapLocation.get().startLocation(_option);
    setState(() {
      _running = true;
    });
  }

  Future<void> _stop() async {
    if (!_running) return;
    await FlutterAMapLocation.get().stopLocation();
    setState(() {
      _running = false;
    });
  }
}

class _LocationWidget extends StatelessWidget {
  final _Data data;

  const _LocationWidget({
    Key key,
    @required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      new Chip(label: new Text('${data.timestamp}')),
    ];

    final location = data.location;

    if (location.errorCode != AMapLocation.LOCATION_SUCCESS) {
      children.addAll([
        new Chip(
          backgroundColor: Colors.red[200],
          label: new Text('Error Code: ${location.errorCode}'),
        ),
        new Chip(
          backgroundColor: Colors.red[200],
          label: new Text('Error Info: ${location.errorInfo}'),
        ),
      ]);
    } else {
      children.addAll([
        new Chip(
          label: new Text('${location.time}'),
        ),
        new Chip(
          label: new Text('Longitude: ${location.longitude}'),
        ),
        new Chip(
          label: new Text('Latitude: ${location.latitude}'),
        ),
        new Chip(
          label: new Text('Accuracy: ${location.accuracy}'),
        ),
      ]);
    }

    return new Wrap(
      children: children,
    );
  }
}
