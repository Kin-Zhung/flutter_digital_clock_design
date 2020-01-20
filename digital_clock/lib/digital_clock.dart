// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  var _temperatureRange = '';
  var _condition = '';

  double _percentHr = 0.0;
  double _percentMin = 0.0;
  double _percentSec = 0.0;
  double _percentDay = 0;
  double _percentMonth = 0;
  double _percentYear = 0;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
    });
  }

  void _updateTime() {
    setState(() {
      var currMonth = new DateTime(_dateTime.year, _dateTime.month, 1);
      var nextMonth = new DateTime(_dateTime.year, _dateTime.month + 1, 1);
      int diffInDays = nextMonth.difference(currMonth).inDays;

      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      _percentHr = _dateTime.hour / 24;
      _percentMin = _dateTime.minute / 60;
      _percentSec = _dateTime.second / 60;
      _percentDay = _dateTime.weekday / 7;
      _percentMonth = _dateTime.day / diffInDays;
      if (_dateTime.year % 4 == 0) {
        _percentYear = _dateTime.day / 365;
      } else {
        _percentYear = _dateTime.day / 366;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final day = DateFormat('dd').format(_dateTime);
    final month = DateFormat('MMM').format(_dateTime);
    final weekDay = DateFormat('EEEE').format(_dateTime);
    final year = DateFormat('y').format(_dateTime);
    return Container(
      color: Color.fromRGBO(0, 0, 0, 1),
      child: Stack(
        children: <Widget>[
          Positioned(
              left: 0,
              top: 0,
              child: Column(children: <Widget>[
                Text(
                  weekDay,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                LinearPercentIndicator(
                  width: 125,
                  lineHeight: 15.0,
                  percent: _percentDay,
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Colors.purple,
                  backgroundColor: Colors.green[200],
                ),
                Text(
                  month,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                CircularPercentIndicator(
                  animation: true,
                  animateFromLastPercent: true,
                  radius: 75.0,
                  lineWidth: 7.0,
                  percent: _percentMonth,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: new Text(
                    day,
                    style: TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  progressColor: Colors.yellow,
                  backgroundColor: Colors.purple[200],
                ),
                Text(
                  year,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                LinearPercentIndicator(
                  width: 125,
                  lineHeight: 15.0,
                  percent: _percentYear,
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Colors.orange,
                  backgroundColor: Colors.yellow[200],
                ),
              ])),
          Positioned(
            left: 105,
            top: 0,
            child: new CircularPercentIndicator(
              animation: true,
              animateFromLastPercent: true,
              radius: 210.0,
              lineWidth: 20.0,
              percent: _percentHr,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.green,
              backgroundColor: Colors.blue[200],
            ),
          ),
          Positioned(
            left: 125,
            top: 22,
            child: new CircularPercentIndicator(
              animation: true,
              animateFromLastPercent: true,
              radius: 170.0,
              lineWidth: 15.0,
              percent: _percentMin,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.red[200],
              progressColor: Colors.blue,
            ),
          ),
          Positioned(
            left: 140,
            top: 39,
            child: new CircularPercentIndicator(
              animation: true,
              animateFromLastPercent: true,
              radius: 140.0,
              lineWidth: 10.0,
              percent: _percentSec,
              center: Container(
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 30,
                      left: 45,
                      child: Text(
                        _condition,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Positioned(
                      top: 58,
                      left: 24,
                      child: Text(
                        _temperatureRange,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    Positioned(
                      top: 75,
                      left: 25,
                      child: Text(
                        hour + ':' + minute,
                        style: TextStyle(color: Colors.white, fontSize: 37),
                      ),
                    ),
                  ],
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.grey,
              progressColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
