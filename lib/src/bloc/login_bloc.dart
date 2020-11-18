// Logica para trabajar con el formulario

import 'dart:async';

import 'package:formvalidation/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  // Recuperar datos del Stream
  Stream<String> get emailStream =>
      _emailController.stream.transform(validarEmail);
  Stream<String> get passwordStream =>
      _passwordController.stream.transform(validarPassword);

  // Unimos las dos validaciones para activar el botón de ingresar
  //Stream<bool> get formValidStream => Observable.combineLatest2(emailStream, passwordStream, (e, p) => true);

  Stream<bool> get formValidStream =>
      CombineLatestStream(emailStream, passwordStream, (e, p) => true);

  // Insertar valores al Stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  // Cerrar controlador

  dispose() {
    _emailController?.close();
    _passwordController?.close();
  }
}
