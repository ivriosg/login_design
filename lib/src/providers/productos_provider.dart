// Es el encargado de conectarse a la BD
import 'dart:convert';
import 'dart:io';
import 'package:formvalidation/src/preferencias_usuario/preferencias_usuario.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

import 'package:http/http.dart' as http;
import 'package:formvalidation/src/models/producto_model.dart';

class ProductosProvider {
  final String _url = 'https://flutter-varios-f924e.firebaseio.com';

  final _prefs = new PreferenciasUsuario();

  // Creamos un producto en la BD
  Future<bool> crearProducto(ProductoModel producto) async {
    // Asignamos URL para publicar el post
    final url = '$_url/productos.json?auth=${_prefs.token}';

    final resp = await http.post(url, body: productoModelToJson(producto));
    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  // Editar producto de la BD
  Future<bool> editarProducto(ProductoModel producto) async {
    // Asignamos URL para publicar el post
    final url = '$_url/productos/${producto.id}.json?auth=${_prefs.token}';

    final resp = await http.put(url, body: productoModelToJson(producto));
    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  // Obtenemos los productos de la BD
  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/productos.json?auth=${_prefs.token}';
    final resp = await http.get(url);

    // Definimos como viene la información
    final Map<String, dynamic> decodedData = json.decode(resp.body);

    // Almacenamos los productos en una lista
    final List<ProductoModel> productos = new List();

    // Verificamos que contenga información el json
    if (decodedData == null) return [];

    // Verificamos si el token de la sesión ya expiro
    if (decodedData['error'] != null) return [];

    decodedData.forEach((id, prod) {
      final prodTemp = ProductoModel.fromJson(prod);
      prodTemp.id = id;

      // Almacenamos el id de prodTemp en la lista productos
      productos.add(prodTemp);
    });

    return productos;
  }

  // Eliminar productos
  Future<int> borrarProducto(String id) async {
    final url = '$_url/productos/$id.json?auth=${_prefs.token}';
    final resp = await http.delete(url);
    print(resp.body);

    return 1;
  }

  // Procesamos la carga de la imagen a un servicio
  Future<String> subirImagen(File imagen) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dckwshetj/image/upload?upload_preset=rkttx2om');

    // Separamos la respuesta de la imagen en imagen/extensión
    final mimeType = mime(imagen.path).split('/');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    // Preparando archivo para subirlo
    final file = await http.MultipartFile.fromPath('file', imagen.path,
        // Colocamos la estructura de la foto en imagen/extensión
        contentType: MediaType(mimeType[0], mimeType[1]));

    // Subimos la imagen al imageUploadRequest
    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Ocurrió un error');
      print(resp.body);
      return null;
    }

    final respData = json.decode(resp.body);

    print(respData);
    return respData['secure_url'];
  }
}
