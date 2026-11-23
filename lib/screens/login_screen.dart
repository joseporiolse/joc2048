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

  // Controladors dels camps de text
  final TextEditingController _controladorUsuari =
  TextEditingController();

  final TextEditingController _controladorContrasena =
  TextEditingController();

  // DAO per consultar els usuaris de SQLite
  final UsuariDao _usuariDao = UsuariDao();

  // Indica si estem comprovant les credencials
  bool _carregant = false;

  // Permet mostrar o amagar la contrasenya
  bool _mostrarContrasena = false;

  // Alliberem els controladors quan es tanca la pantalla
  @override
  void dispose() {
    _controladorUsuari.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  // Mostrem o amaguem la contrasenya
  void _canviarVisibilitat() {
    setState(() {
      _mostrarContrasena = !_mostrarContrasena;
    });
  }

  // Comprovem les dades i iniciem la sessió
  Future<void> _iniciarSessio() async {

    final String nom = _controladorUsuari.text.trim();
    final String contrasena = _controladorContrasena.text;

    // Comprovem que els camps no estiguin buits
    if (nom.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has d\'omplir tots els camps.'),
        ),
      );
      return;
    }

    // Mostrem l'indicador de càrrega
    setState(() {
      _carregant = true;
    });

    try {

      // Consultem l'usuari a SQLite
      final Usuari? usuari = await _usuariDao.iniciarSessio(
        nom,
        contrasena,
      );

      if (!mounted) return;

      if (usuari == null) {

        // Les credencials no són correctes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nom d\'usuari o contrasenya incorrectes.',
            ),
          ),
        );

      } else {

        // Hem iniciat sessió correctament
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Benvingut/da, ${usuari.usuari}!',
            ),
          ),
        );

        // Retornem l'usuari autenticat
        // La pantalla principal rebrà aquest resultat
        Navigator.pop(context, usuari);
      }

    } catch (error) {

      if (!mounted) return;

      // Mostrem un missatge si falla la consulta
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

  // Obrim la pantalla de registre
  void _anarARegistre() {

    // Aquesta ruta la configurarem quan
    // creem la pantalla de registre
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

                // Icona principal
                Icon(
                  Icons.sports_esports,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                // Títol de la pantalla
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

                // Camp del nom d'usuari
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

                // Camp de la contrasenya
                TextField(
                  controller: _controladorContrasena,
                  obscureText: !_mostrarContrasena,
                  onSubmitted: (_) => _iniciarSessio(),
                  decoration: InputDecoration(
                    labelText: 'Contrasenya',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),

                    // Botó per mostrar o amagar la contrasenya
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

                // Botó d'inici de sessió
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

                // Botó per registrar un usuari nou
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
