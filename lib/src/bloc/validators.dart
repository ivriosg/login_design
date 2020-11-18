import 'dart:async';

class Validators {
  // Validamos el email
  final validarEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      // Ingresamos la expresion regular para el email
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = new RegExp(pattern);

      if (regExp.hasMatch(email)) {
        sink.add(email);
      } else {
        sink.addError('El email no es valido');
      }
    },
  );

  // Validamos el password
  final validarPassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      // Verificar que tenga 6 caracteres
      if (password.length >= 6) {
        sink.add(password);
      } else {
        sink.addError('El password debe de tener 6 caracteres.');
      }
    },
  );
}
