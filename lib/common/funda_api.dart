import 'package:dio/dio.dart';
import 'package:either_option/either_option.dart';
import 'package:funda/common/http_client.dart';
import 'package:funda/common/model/error.dart';
import 'package:funda/common/model/property.dart';

const _propertyEndpoint = '/feeds/Aanbod.svc/json/detail/[key]/koop/[id]/';

class FundaApi {
  FundaApi(this.client);

  final HttpClient client;

  Future<Either<RemoteError, Property>> getProperty(String propertyId) async =>
      executeSafely(client.getJson(_propertyEndpoint.replaceAll('[id]', propertyId)), Property.fromJson);
}

Future<Either<RemoteError, T>> executeSafely<R, T>(
  Future<R?> networkRequest,
  T Function(R) converter,
) async {
  try {
    final result = await networkRequest;
    if (result == null) {
      return Left(RemoteError.unexpected());
    } else {
      return Right(converter(result));
    }
  } on DioError catch (error) {
    if (error.type == DioErrorType.other) {
      return Left(RemoteError.network()); //todo network?
    } else {
      return Left(RemoteError.server(1, 'message')); //todo network?
    }
  } catch (error, st) {
    return Left(RemoteError.unexpected(error.toString()));
  }
}