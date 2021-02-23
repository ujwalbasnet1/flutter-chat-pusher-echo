import 'package:flutter_pusher/pusher.dart';

// import 'package:flutter_pusher_client/flutter_pusher.dart';
import 'package:laravel_echo/laravel_echo.dart';

class TestPusher {
  PusherOptions options;

  TestPusher() {
    String token = "EZncdc7WbfCyzoUUiufMO1xKbeKCmA";
    String userId = "b71f86df-e108-4e8e-bd24-c541fb9f07ec";

    options = PusherOptions(
      host: 'ncic.64robots.com',
      encrypted: false,
      cluster: "ap2",
      auth: PusherAuth(
        'https://ncic.64robots.com/scheduling/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      ),
    );
    // PusherOptions.setAuthorizer();
    initialize(token, userId);
  }

  void initialize(String token, String userId) async {
    // PusherClient pusher = PusherClient(
    //   "fddfbbf565074873a8e0",
    //   options,
    //   enableLogging: true,
    // );
    // connect at a later time than at instantiation.
    try {
      // pusher.connect();
      Pusher pusher = await Pusher.init(
        'fddfbbf565074873a8e0',
        options,
        enableLogging: true,
        // onConnectionStateChange: (ConnectionStateChange events) =>
        //     print("${events.currentState}"),
        // onError: (ConnectionError e) =>
        //     print("Error occurred logging you in with auth tokens ${e.toJson()}"),
      );
      // pusher.connect();

      Pusher.connect(
        onConnectionStateChange: (ConnectionStateChange state) =>
            print("ON CONNECTION STATE CHANGE ${state.currentState}"),
        onError: (ConnectionError err) => print("ONERROR ${err.toJson()}"),
      );

      var echo = new Echo({
        'broadcaster': 'pusher',
        'authEndpoint':
            'https://ncic.64robots.com/scheduling/broadcasting/auth',
        'key': "fddfbbf565074873a8e0",
        'wsHost': 'ncic.64robots.com',
        'wsPort': 6002,
        'wssPort': 6002,
        'disableStats': false,
        'enabledTransports': ['ws', 'wss'],
        'client': pusher,
        'auth': {
          'headers': {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }
        }
      });

// Subscribe to a private channel
      echo
          .private('user.$userId')
          .listen('InmateRestriction\\InmateRestrictionCreated', (e) {
        print("Data Recieved: $e");
      });
    } catch (e) {
      print("A PUSHER ERROR $e");
    }
    //
  }
}
