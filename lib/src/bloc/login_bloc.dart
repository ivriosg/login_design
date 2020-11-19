// Logica para trabajar con el formulario

import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:formvalidation/src/bloc/validators.dart';

class LoginBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  // Recuperar datos del Stream
  Stream<String> get emailStream =>
      _emailController.stream.transform(validarEmail);
  Stream<String> get passwordStream =>
      _passwordController.stream.transform(validarPassword);

  // Unimos las dos validaciones para activar el botón de ingresar
  Stream<bool> get formValidStream =>
      Rx.combineLatest2(emailStream, passwordStream, (e, p) => true);

  // Insertar valores al Stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  // Obtner el último valor ingresado a los Streams
  String get email => _emailController.value;
  String get password => _passwordController.value;

  // Cerrar controlador
  dispose() {
    _emailController?.close();
    _passwordController?.close();
  }
}
