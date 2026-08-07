import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/history_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/presenca.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/student_avatar.dart';

/// Tela de Histórico — registros de entrada/saída com busca e filtros.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryController()..carregar(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HistoryController>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text(AppStrings.historico)),
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              // Busca + filtros ficam fixos acima da lista.
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.pagePadding(context).horizontal / 2,
                  8,
                  Responsive.pagePadding(context).horizontal / 2,
                  0,
                ),
                child: AppInput(
                  hint: AppStrings.buscarAluno,
                  icon: Icons.search,
                  onChanged: controller.buscar,
                ),
              ),
              const SizedBox(height: 12),
              const _FiltroChips(),
              const SizedBox(height: 4),
              Expanded(
                child: controller.carregando
                    ? const AppLoading(mensagem: AppStrings.carregando)
                    : _ListaRegistros(registros: controller.registros),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha horizontal de chips de filtro por situação.
class _FiltroChips extends StatelessWidget {
  const _FiltroChips();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HistoryController>();

    return FilterChipsBar<StatusPresenca?>(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context).horizontal / 2,
      ),
      selecionado: controller.filtroStatus,
      onSelecionar: (status) =>
          context.read<HistoryController>().filtrarPorStatus(status),
      itens: [
        const FilterChipItem(label: 'Todos', value: null),
        for (final status in StatusPresenca.values)
          FilterChipItem(label: status.label, value: status),
      ],
    );
  }
}

/// Lista de registros com pull-to-refresh e estado vazio.
class _ListaRegistros extends StatelessWidget {
  final List<Presenca> registros;

  const _ListaRegistros({required this.registros});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HistoryController>().carregar(),
      child: registros.isEmpty
          // ListView com física "sempre rolável" para que o gesto de
          // pull-to-refresh continue funcionando mesmo sem resultados.
          ? LayoutBuilder(
              builder: (context, constraints) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: const EmptyState(mensagem: AppStrings.nenhumRegistro),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: Responsive.pagePadding(context),
              itemCount: registros.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _RegistroCard(presenca: registros[index]),
            ),
    );
  }
}

/// Card de um registro de presença (aluno, entrada, saída, data, status).
class _RegistroCard extends StatelessWidget {
  final Presenca presenca;

  const _RegistroCard({required this.presenca});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              StudentAvatar(aluno: presenca.aluno),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(presenca.aluno.nome, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'RA ${presenca.aluno.ra} • ${presenca.aluno.turma}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: presenca.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _DadoRegistro(
                icone: Icons.login,
                rotulo: AppStrings.entrada,
                valor: presenca.entrada != null
                    ? AppFormatters.hora(presenca.entrada!)
                    : '--:--',
              ),
              _DadoRegistro(
                icone: Icons.logout,
                rotulo: AppStrings.saida,
                valor: presenca.saida != null
                    ? AppFormatters.hora(presenca.saida!)
                    : '--:--',
              ),
              _DadoRegistro(
                icone: Icons.calendar_today_outlined,
                rotulo: 'Data',
                valor: AppFormatters.dataCurta(presenca.data),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DadoRegistro extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _DadoRegistro({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Row(
        children: [
          Icon(
            icone,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo,
                  style: textTheme.bodySmall?.copyWith(fontSize: 11)),
              Text(
                valor,
                style: textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
