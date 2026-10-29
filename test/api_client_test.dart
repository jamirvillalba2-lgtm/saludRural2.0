import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:salud_rural/services/api_client.dart';
import 'package:salud_rural/services/cita_api_service.dart';
import 'package:salud_rural/services/doctor_api_service.dart';

void main() {
  group('API REST services', () {
    test('filters doctors by specialty', () async {
      late Uri requestUri;
      final client = ApiClient(
        baseUrl: 'http://localhost:3000/api',
        client: MockClient((request) async {
          requestUri = request.url;
          return http.Response(
            jsonEncode([
              {'id': 'doc-1', 'nombre': 'Dra. Rural'},
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final doctors = await DoctorApiService(client).listar(
        especialidad: 'Medicina general',
      );

      expect(requestUri.path, '/api/doctores');
      expect(requestUri.queryParameters['especialidad'], 'Medicina general');
      expect(doctors.single['id'], 'doc-1');
    });

    test('surfaces a concurrent booking conflict as a clear API error',
        () async {
      final client = ApiClient(
        baseUrl: 'http://localhost:3000/api',
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({'message': 'Horario ocupado'}),
            409,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await expectLater(
        CitaApiService(client).crear({'doctorId': 'doc-1'}),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having((error) => error.message, 'message', 'Horario ocupado'),
        ),
      );
    });

    test('lists, updates, and cancels appointments through REST endpoints',
        () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        baseUrl: 'http://localhost:3000/api',
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'data': {
                  'citas': [
                    {'id': 'cita-1'},
                  ],
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('', request.method == 'DELETE' ? 204 : 200);
        }),
      );
      final service = CitaApiService(client);

      final citas = await service.listar(documentoPaciente: '12345');
      await service.actualizar('cita-1', {'estado': 'CONFIRMADA'});
      await service.cancelar('cita-1');

      expect(citas.single['id'], 'cita-1');
      expect(requests[0].method, 'GET');
      expect(requests[0].url.queryParameters['documentoPaciente'], '12345');
      expect(requests[1].method, 'PUT');
      expect(requests[1].url.path, '/api/citas/cita-1');
      expect(requests[2].method, 'DELETE');
      expect(requests[2].url.path, '/api/citas/cita-1');
    });
  });
}
