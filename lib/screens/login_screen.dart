import 'package:flutter/material.dart';
import '../data/usuari_dao.dart';
import '../models/usuari.dart';
import '../services/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _controladorUsuari =
  TextEditingController();

  final TextEditingController _controladorContrasena =
  TextEditingController();

  final UsuariDao _usuariDao = UsuariDao();

  bool _carregant = false;

  //Permet mostrar o amagar la contrasenya
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _controladorUsuari.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  //Mostrem o amaguem la contrasenya
  void _canviarVisibilitat() {
    setState(() {
      _mostrarContrasena = !_mostrarContrasena;
    });
  }

  //Comprovem les dades i iniciem la sessió
  Future<void> _iniciarSessio() async {

    final String nom = _controladorUsuari.text.trim();
    final String contrasena = _controladorContrasena.text;

    if (nom.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has d\'omplir tots els camps.'),
        ),
      );
      return;
    }

    setState(() {
      _carregant = true;
    });

    try {

      final Usuari? usuari = await _usuariDao.iniciarSessio(
        nom,
        contrasena,
      );

      if (!mounted) return;

      if (usuari == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nom d\'usuari o contrasenya incorrectes.',
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Benvingut/da, ${usuari.usuari}!',
            ),
          ),
        );

        Navigator.pop(context, usuari);
      }

    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No s\'ha pogut iniciar la sessió.',
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _carregant = false;
        });
      }
    }
  }

  void _anarARegistre() {

    Navigator.pushNamed(
      context,
      '/registre',
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sessió'),
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

                Icon(
                  Icons.sports_esports,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                const Text(
                  'Benvingut al 2048!',
                  textAlign: TextAlign.center,
                  style: AppTheme.estilTitol,
                ),

                const SizedBox(
                  height: AppTheme.espaiPetit,
                ),

                const Text(
                  'Inicia sessió per guardar les teves partides.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

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

                TextField(
                  controller: _controladorContrasena,
                  obscureText: !_mostrarContrasena,
                  onSubmitted: (_) => _iniciarSessio(),
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
                  height: AppTheme.espaiGran,
                ),

                ElevatedButton(
                  onPressed: _carregant ? null : _iniciarSessio,

                  child: _carregant
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Iniciar sessió'),
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                TextButton(
                  onPressed: _anarARegistre,
                  child: const Text(
                    'No tens compte? Registra\'t',
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
