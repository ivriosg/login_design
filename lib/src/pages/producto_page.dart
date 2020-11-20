import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:formvalidation/src/models/producto_model.dart';

class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  // Key única para mpodificar el estado
  final formKey = GlobalKey<FormState>();

  // Key única para dar retroalimentación
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ProductosBloc productosBloc;
  ProductoModel producto = new ProductoModel();

  // Evitamos guardar multiples ocasiones el producto
  bool _guardando = false;

  // Creamos propiedad para almacenar la fotografía
  File foto;

  @override
  Widget build(BuildContext context) {
    productosBloc = Provider.productosBloc(context);
    // Verificamos si vamos a editar un producto
    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    // Asigno la información de la BD a podData
    if (prodData != null) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(producto.titulo),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            // Identificador único del formulario
            key: formKey,
            child: Column(
              children: [
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _crearNombre() {
    // TextFormField es para colocar texto en un formulario
    return TextFormField(
      // Obtnemos el valor por defecto
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: 'Producto'),
      // Asignamos el texto del usuario al producto
      onSaved: (value) => producto.titulo = value,
      // Validando la información del usuario
      validator: (value) {
        if (value.length < 3) {
          return 'Ingresa el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }

  _crearPrecio() {
    return TextFormField(
      // Obtnemos el valor por defecto
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Precio'),
      // Asignamos el texto del usuario al producto
      onSaved: (value) => producto.valor = double.parse(value),
      // Validando el precio
      validator: (value) {
        // Obtenemos la validación del archivo utils
        if (utils.isNumeric(value)) {
          return null;
        } else {
          return 'Sólo números';
        }
      },
    );
  }

  _crearDisponible() {
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState(() {
        producto.disponible = value;
      }),
    );
  }

  _crearBoton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      color: Colors.deepPurple,
      textColor: Colors.white,
      label: Text('Guardar'),
      icon: Icon(Icons.save),
      // Validamos que el producto no se guarde multiples ocasiones
      onPressed: (_guardando) ? null : _submit,
    );
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    final _picker = ImagePicker();

    final pickedFile = await _picker.getImage(
      source: origen,
    );

    foto = File(pickedFile.path);

    if (foto != null) {
      producto.fotoUrl = null;
    }

    setState(() {});
  }

  // Validación del botón
  void _submit() async {
    if (!formKey.currentState.validate()) return;

    // Guardamos la información
    formKey.currentState.save();

    // Actualizamos el valor para no guardar el mismo producto
    setState(() {
      _guardando = true;
    });

    // Verificamos que la imagen se suba
    if (foto != null) {
      // Guardamos foto en Firebase
      producto.fotoUrl = await productosBloc.subirFoto(foto);
    }

    if (producto.id == null) {
      productosBloc.agregarProducto(producto);
    } else {
      productosBloc.editarProducto(producto);
    }
    _mostrarSnackbar('Producto Guardado');

    // Redireccionamos al usuario a la pagina principal
    Navigator.pop(context);
  }

  void _mostrarSnackbar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  _mostrarFoto() {
    if (producto.fotoUrl != null) {
      return FadeInImage(
        image: NetworkImage(producto.fotoUrl),
        placeholder: AssetImage('assets/jar-loading.gif'),
        height: 300.0,
        fit: BoxFit.contain,
      );
    } else {
      return Image(
        image: AssetImage(foto?.path ?? 'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }
}
