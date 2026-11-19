/// Errores "crudos" que lanza la capa de datos.
class ServerException implements Exception {
  const ServerException([this.statusCode]);

  final int? statusCode;
}
