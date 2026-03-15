import 'package:latlong2/latlong.dart';

void main() {
  String polyline = 'q~e`Ayn|eTd@p@^j@Zf@`@v@Xr@N^?H?N_@tCIn@?BDBHDJDD@DCHIHGJGBEBMBKBEBGBIA[EOEOAICMASC[M[WSSOOw@q@{@w@cBsAeDuCoA{AI?iA}AYkA';
  final points = decodePolyline(polyline);
  print('Decoded ${points.length} points.');
  if (points.isNotEmpty) {
    print('First point: ${points.first.latitude}, ${points.first.longitude}');
    print('Last point: ${points.last.latitude}, ${points.last.longitude}');
  }
}

  List<LatLng> decodePolyline(String encodedPolyline) {
    List<LatLng> polylineCoords = [];
    int index = 0, len = encodedPolyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      try {
        int b, shift = 0, result = 0;
        do {
          b = encodedPolyline.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          if (index >= len) break;
          b = encodedPolyline.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        polylineCoords.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
      } catch (e) {
        break;
      }
    }
    return polylineCoords;
  }
