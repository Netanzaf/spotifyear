import 'dart:convert';
import 'dart:io';

class Authorization {
  Authorization({this.clientId, this.clientSecret});

  static final redirectUri =
      Uri(host: InternetAddress.loopbackIPv4.address, port: 4040);

  final String clientId;
  final String clientSecret;

  String accessToken;

  Future<void> authorize() async {
    var redirect = await _server(redirectUri);

    await _retrieveAccessToken(
        redirect: redirect,
        code: await _code(redirect).asBroadcastStream().first);
  }

  Stream<String> _code(Stream<HttpRequest> redirect) async* {
    await Process.run(
        'start',
        [
          'https://accounts.spotify.com/authorize?client_id=${clientId}^&response_type=code^&redirect_uri=http:${redirectUri}^&scope=user-library-read'
        ],
        runInShell: true);

    await for (var request in redirect) {
      if (request.uri.queryParameters.containsKey('code')) {
        yield request.uri.queryParameters['code'];
        request.response.write('access has been granted');
        await request.response.close();
      }
    }
  }

  Future<void> _retrieveAccessToken(
      {Stream<HttpRequest> redirect, String code}) async {
    var authorizationHeader =
        base64.encode(utf8.encode('${clientId}:${clientSecret}'));

    var accessTokenRequest = await HttpClient().postUrl(Uri.parse(
        'https://accounts.spotify.com/api/token?grant_type=authorization_code&code=$code&redirect_uri=http:$redirectUri'))
      ..headers.set('content-type', 'application/x-www-form-urlencoded')
      ..headers.add('Authorization', 'Basic ${authorizationHeader}');

    var accessTokenResponse = await accessTokenRequest.close();

    await for (var data in accessTokenResponse
        .transform(utf8.decoder)
        .transform(json.decoder)) {
      accessToken = (data as Map)['access_token'];
    }
  }

  Future<Stream<HttpRequest>> _server(Uri uri) async {
    return (await HttpServer.bind(uri.host, uri.port)).asBroadcastStream();
  }
}
