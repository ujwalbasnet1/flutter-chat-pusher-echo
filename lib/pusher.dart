import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client/pusher_client.dart';

// import 'package:npusher/npusher.dart';

String cookie =
    "XSRF-TOKEN=eyJpdiI6IkdcL3pZSjBOVUNCSG83WFh5MHByQktBPT0iLCJ2YWx1ZSI6IkJWTU1FWjBaTWRXU0dqNFRDaWxqXC8rNU9DSzZPN2MwQnliaFFTdDlmbU5NV1J5MWVuTHRwREZ6ZDlLOTFjN3VhSDdYN2FmclV2WU1ydStzeityOFZlZz09IiwibWFjIjoiMGM4YTZmNWJkZjhhMjRmMDcyNmJmYTMxNmRhN2JlYWY4OTFjYTRmZDgzMzk0MTVlY2JiYTY3NmU3NGQxMWRhOCJ9; laravel_session=eyJpdiI6IjBYUWFyZjZtK0YwSzlES2dtXC82YnRnPT0iLCJ2YWx1ZSI6IjVCU2ZWa09MQ2xmY3dGK3ZLclZcL0xpTFJzcVd2cktDU1JGY1E2T3FkaDRaeWIzMDhzd1BkT1EwUUtjTEw4SVhtY2o5Q2lYdEs5VWxRbGZcL3BJVzhSMlE9PSIsIm1hYyI6ImU3ODNiNTFlODk2YmFlYWRhNTNhZTQ0YzQ5YWVjZGQxMTI4MTg3OGNiNTQwMGY2NjA5OTdhNzRiMTQxOWI1NmQifQ%3D%3D";

String csrf = "QSFnbaFojYY67bDxIKNK2LPevTBpdPba0PLqtZYb";

class TestPusher {
  PusherClient _pusher; //= PusherClient();

  String _link = "http://192.168.0.2";
  String _host = "192.168.0.2";

  TestPusher() {
    _pusher = PusherClient(
      "bf2b22c04dc5ab58772f",
      PusherOptions(
        host: _host,
        // wsPort: 6002,
        encrypted: false,
        cluster: "ap2",
        auth: PusherAuth(
          "$_link/broadcasting/auth",
          headers: <String, String>{
            "Cookie": cookie,
            "X-CSRF-TOKEN": csrf,
            // 'Content-Type': 'application/json',
            // 'Accept': 'application/json'
          },
        ),
      ),
      enableLogging: true,
    );

    initialize();
  }

  bool connected = false;

  onConnected(state) {
    String currentState = state.currentState;
    String previousState = state.previousState;

    print("PUSHER STATES $currentState");

    if (currentState.toLowerCase() == 'connected' && !connected) {
      connected = true;

      _pusher.subscribe("my-channel").bind("my-event", (event) {
        print("MY CHANNEL PUSHER ${event.data}");
      });

      var echo = new Echo({
        'broadcaster': 'pusher',
        'client': _pusher,
        // "wsPort": 6002,
        'auth': {
          'headers': {
            "Cookie": cookie,
            "X-CSRF-TOKEN": csrf,
            //     'Authorization': 'Bearer $token',
            //     // 'Accept': '*/*',
            //     // 'Content-Type': "application/json"
          }
        },
        'authEndpoint': '$_link/broadcasting/auth',
        // 'key': "bf2b22c04dc5ab58772f",
        // 'host': '$_link',
        // 'wsPort': 6002,
        // 'encrypted': false,
        // 'disableStats': false,
        // 'enabledTransports': ['ws', 'wss'],
        // "wsHost": _host,
        // "httpHost": _host,
        "disableStats": true,
        "forceTLS": false,
        "enabledTransports": ['ws', 'wss'],
      });

      echo.private('chat').listen('MessageSent', (PusherEvent e) {
        print("MESSAGE SENT ${e.data}");
      });
    }
  }

  initialize() async {
    print("------ INITIALIZE PUSHER ------");

    try {
      await _pusher.connect();
    } catch (e) {
      print("PUSHER CATCH");
      print(e);
    }
    _pusher.onConnectionStateChange((state) {
      onConnected(state);
    });

    _pusher.onConnectionError((error) {
      print("PUSHER ERROR ${error.toJson()}");
    });
  }
}
