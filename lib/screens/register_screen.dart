import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../data/usuari_dao.dart';
import '../models/usuari.dart';
import '../services/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // Controladors dels camps del formulari
  final TextEditingController _controladorUsuari =
  TextEditingController();

  final TextEditingController _controladorEmail =
  TextEditingController();

  final TextEditingController _controladorContrasena =
  TextEditingController();

  final TextEditingController _controladorConfirmacio =
  TextEditingController();

  // DAO per gestionar els usuaris
  final UsuariDao _usuariDao = UsuariDao();

  // Control de l'estat de la pantalla
  bool _carregant = false;
  bool _mostrarContrasena = false;

  // Alliberem els controladors
  @override
  void dispose() {
    _controladorUsuari.dispose();
    _controladorEmail.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmacio.dispose();
    super.dispose();
  }

  // Mostrem o amaguem la contrasenya
  void _canviarVisibilitat() {
    setState(() {
      _mostrarContrasena = !_mostrarContrasena;
    });
  }

  // Mostrem un missatge amb SnackBar
  void _mostrarMissatge(String missatge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(missatge),
      ),
    );
  }

  // Validem les dades i registrem l'usuari
  Future<void> _registrar() async {

    final String nom = _controladorUsuari.text.trim();
    final String email = _controladorEmail.text.trim();
    final String contrasena = _controladorContrasena.text;
    final String confirmacio = _controladorConfirmacio.text;

    // Comprovem que tots els camps estiguin emplenats
    if (nom.isEmpty ||
        email.isEmpty ||
        contrasena.isEmpty ||
        confirmacio.isEmpty) {
      _mostrarMissatge('Has d\'omplir tots els camps.');
      return;
    }

    // Comprovem el format del correu electrònic
    final RegExp expressioEmail =
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!expressioEmail.hasMatch(email)) {
      _mostrarMissatge('El correu electrònic no és vàlid.');
      return;
    }

    // Comprovem que les contrasenyes coincideixin
    if (contrasena != confirmacio) {
      _mostrarMissatge('Les contrasenyes no coincideixen.');
      return;
    }

    // Exigim una longitud mínima de contrasenya
    if (contrasena.length < 8) {
      _mostrarMissatge(
        'La contrasenya ha de tenir almenys 8 caràcters.',
      );
      return;
    }

    setState(() {
      _carregant = true;
    });

    try {

      // Comprovem si el nom d'usuari ja existeix
      final Usuari? existent =
      await _usuariDao.obtenirPerNom(nom);

      if (!mounted) return;

      if (existent != null) {
        _mostrarMissatge(
          'Aquest nom d\'usuari ja està registrat.',
        );
        return;
      }

      // Creem l'usuari amb la data actual en format ISO
      final Usuari usuari = Usuari(
        usuari: nom,
        email: email,
        contrasena: contrasena,
        dataRegistre: DateTime.now().toIso8601String(),
      );

      // Guardem l'usuari a SQLite
      // El DAO aplica BCrypt a la contrasenya
      await _usuariDao.registrar(usuari);

      if (!mounted) return;

      _mostrarMissatge(
        'Usuari registrat correctament!',
      );

      // Tornem a la pantalla d'inici de sessió
      Navigator.pop(context);

    } on DatabaseException catch (error) {

      if (!mounted) return;

      // Detectem errors de restricció UNIQUE
      if (error.isUniqueConstraintError()) {
        _mostrarMissatge(
          'El nom d\'usuari o el correu ja estan registrats.',
        );
      } else {
        _mostrarMissatge(
          'No s\'ha pogut registrar l\'usuari.',
        );
      }

    } catch (error) {

      if (!mounted) return;

      _mostrarMissatge(
        'S\'ha produït un error durant el registre.',
      );

    } finally {

      if (mounted) {
        setState(() {
          _carregant = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear compte'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppTheme.espaiGran,
          ),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Icona de registre
                Icon(
                  Icons.person_add,
                  size: 70,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                const Text(
                  'Crea el teu compte',
                  textAlign: TextAlign.center,
                  style: AppTheme.estilTitol,
                ),

                const SizedBox(
                  height: AppTheme.espaiPetit,
                ),

                const Text(
                  'Registra\'t per guardar les teves puntuacions.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

                // Nom d'usuari
                TextField(
                  controller: _controladorUsuari,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'usuari',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                // Correu electrònic
                TextField(
                  controller: _controladorEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correu electrònic',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                // Contrasenya
                TextField(
                  controller: _controladorContrasena,
                  obscureText: !_mostrarContrasena,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Contrasenya',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _canviarVisibilitat,
                      icon: Icon(
                        _mostrarContrasena
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                // Confirmació de la contrasenya
                TextField(
                  controller: _controladorConfirmacio,
                  obscureText: !_mostrarContrasena,
                  onSubmitted: (_) => _registrar(),
                  decoration: const InputDecoration(
                    labelText: 'Confirma la contrasenya',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

                // Botó per crear el compte
                ElevatedButton(
                  onPressed: _carregant ? null : _registrar,

                  child: _carregant
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Registrar-me'),
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                // Tornem a l'inici de sessió
                TextButton(
                  onPressed: _carregant
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    'Ja tens compte? Inicia sessió',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
