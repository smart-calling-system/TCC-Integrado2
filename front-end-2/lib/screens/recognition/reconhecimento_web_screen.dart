import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// 👇 Aqui está o pacote que controla as regras exclusivas do Android
import 'package:webview_flutter_android/webview_flutter_android.dart'; 
import 'package:permission_handler/permission_handler.dart';

class ReconhecimentoWebScreen extends StatefulWidget {
  const ReconhecimentoWebScreen({Key? key}) : super(key: key);

  @override
  State<ReconhecimentoWebScreen> createState() => _ReconhecimentoWebScreenState();
}

class _ReconhecimentoWebScreenState extends State<ReconhecimentoWebScreen> {
  late final WebViewController _controller;
  bool _permissaoConcedida = false;

  @override
  void initState() {
    super.initState();
    _solicitarPermissaoCamera();
  }

  Future<void> _solicitarPermissaoCamera() async {
    // 1. Pede permissão da câmera pro Android nativo
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      // 2. Prepara o Navegador Invisível (WebView)
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('http://localhost:5500/python_api/templates/index.html'));

      // 🔥 MÁGICA DO ANDROID: Aplicamos as permissões e o Autoplay direto no motor do Android!
      if (_controller.platform is AndroidWebViewController) {
        final androidController = _controller.platform as AndroidWebViewController;
        
        // 🕵️‍♂️ MODO HACKER ATIVADO: Permite debugar o WebView pelo Google Chrome no PC!
        AndroidWebViewController.enableDebugging(true);
        
        // Arranca o bloqueio do botão "Play" e força o vídeo a rodar sozinho
        androidController.setMediaPlaybackRequiresUserGesture(false);
        
        // Autoriza o HTML do Pietro a ligar a câmera por baixo dos panos!
        androidController.setOnPlatformPermissionRequest((request) {
          request.grant();
        });
      }
        
      setState(() {
        _permissaoConcedida = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A câmera é obrigatória para a biometria!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Fundo combinando com o Tailwind do Pietro (slate-950)
      body: SafeArea(
        child: _permissaoConcedida
            ? WebViewWidget(controller: _controller)
            : const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
      ),
    );
  }
}