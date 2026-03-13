import 'dart:math';
import 'package:flutter/material.dart';

const int tamanho = 12;
const int totalMinas = 20;
const int mina = -1;
const String imagemBomba = 'assets/images/bomba.png';
const String imagemBandeira = 'assets/images/bandeira.png';

void main() {
  runApp(MaterialApp(
    title: 'Campo Minado',
    home: const JogoCampoMinado(),
  ));
}

class JogoCampoMinado extends StatefulWidget {
  const JogoCampoMinado({super.key});

  @override
  State<JogoCampoMinado> createState() => _EstadoJogo();
}

class _EstadoJogo extends State<JogoCampoMinado> {
  late List<List<int>> tabuleiro;
  late List<List<bool>> reveladas;
  late List<List<bool>> bandeiras;
  bool fimDeJogo = false;
  bool venceu = false;

  @override
  void initState() {
    super.initState();
    novoJogo();
  }

  void novoJogo() {
    tabuleiro = List.generate(tamanho, (_) => List.filled(tamanho, 0));
    reveladas = List.generate(tamanho, (_) => List.filled(tamanho, false));
    bandeiras = List.generate(tamanho, (_) => List.filled(tamanho, false));
    fimDeJogo = false;
    venceu = false;
    colocarMinas();
    calcularNumeros();
  }

  void colocarMinas() {
    final random = Random();
    int colocadas = 0;
    while (colocadas < totalMinas) {
      final l = random.nextInt(tamanho);
      final c = random.nextInt(tamanho);
      if (tabuleiro[l][c] != mina) {
        tabuleiro[l][c] = mina;
        colocadas++;
      }
    }
  }

  void calcularNumeros() {
    for (int l = 0; l < tamanho; l++) {
      for (int c = 0; c < tamanho; c++) {
        if (tabuleiro[l][c] == mina) continue;
        int total = 0;
        for (int dl = -1; dl <= 1; dl++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dl == 0 && dc == 0) continue;
            final nl = l + dl;
            final nc = c + dc;
            if (nl >= 0 && nl < tamanho && nc >= 0 && nc < tamanho) {
              if (tabuleiro[nl][nc] == mina) total++;
            }
          }
        }
        tabuleiro[l][c] = total;
      }
    }
  }

  void toggleBandeira(int l, int c) {
    if (fimDeJogo) return;
    if (reveladas[l][c]) return;
    setState(() {
      bandeiras[l][c] = !bandeiras[l][c];
    });
  }

  void abrirCasa(int linhaInicial, int colunaInicial) {
    if (fimDeJogo) return;
    if (reveladas[linhaInicial][colunaInicial]) return;
    if (bandeiras[linhaInicial][colunaInicial]) return;

    if (tabuleiro[linhaInicial][colunaInicial] == mina) {
      setState(() {
        reveladas[linhaInicial][colunaInicial] = true;
        fimDeJogo = true;
        venceu = false;
      });
      return;
    }

    final pilha = [[linhaInicial, colunaInicial]];
    while (pilha.isNotEmpty) {
      final atual = pilha.removeLast();
      final l = atual[0];
      final c = atual[1];

      if (l < 0 || l >= tamanho || c < 0 || c >= tamanho) continue;
      if (reveladas[l][c]) continue;
      if (tabuleiro[l][c] == mina) continue;

      reveladas[l][c] = true;

      if (tabuleiro[l][c] == 0) {
        for (int dl = -1; dl <= 1; dl++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dl == 0 && dc == 0) continue;
            pilha.add([l + dl, c + dc]);
          }
        }
      }
    }

    int segurasAbertas = 0;
    for (int l = 0; l < tamanho; l++) {
      for (int c = 0; c < tamanho; c++) {
        if (tabuleiro[l][c] != mina && reveladas[l][c]) segurasAbertas++;
      }
    }

    setState(() {
      if (segurasAbertas == (tamanho * tamanho) - totalMinas) {
        fimDeJogo = true;
        venceu = true;
      }
    });
  }

  Color corDoNumero(int valor) {
    switch (valor) {
      case 1: return Colors.blue;
      case 2: return Colors.green[700]!;
      case 3: return Colors.red;
      case 4: return Colors.purple;
      case 5: return Colors.brown;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campo Minado'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (fimDeJogo)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                venceu ? 'Parabens! Voce venceu!' : 'Boom! Voce perdeu!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: venceu ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),

          Center(
            child: SizedBox(
              width: 420,
              height: 420,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: tamanho,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: tamanho * tamanho,
                itemBuilder: (context, index) {
                  final l = index ~/ tamanho;
                  final c = index % tamanho;
                  final aberta = reveladas[l][c];
                  final valor = tabuleiro[l][c];

                  final comBandeira = bandeiras[l][c];

                  return GestureDetector(
                    onTap: () => abrirCasa(l, c),
                    onSecondaryTap: () => toggleBandeira(l, c),
                    child: Container(
                      decoration: BoxDecoration(
                        color: aberta ? Colors.green[50] : Colors.green[700],
                        border: Border.all(color: Colors.green[900]!, width: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: aberta
                            ? (valor == mina
                                ? Image.asset(
                                    imagemBomba,
                                    width: 14,
                                    height: 14,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.circle, size: 12, color: Colors.red[700]),
                                  )
                                : Text(
                                    valor == 0 ? '' : '$valor',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: corDoNumero(valor),
                                    ),
                                  ))
                            : comBandeira
                                ? Image.asset(
                                    imagemBandeira,
                                    width: 14,
                                    height: 14,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.flag, size: 12, color: Colors.red[700]),
                                  )
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => setState(() => novoJogo()),
            icon: Icon(Icons.refresh),
            label: Text('Novo Jogo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
