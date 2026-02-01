import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/report/report_cubit.dart';
import '../bloc/report/report_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  void _onDownloadPressed(BuildContext context) {
    context.read<ReportCubit>().downloadAndOpenReport();
  }

  void _onRetry(BuildContext context) {
    context.read<ReportCubit>().reset();
    context.read<ReportCubit>().downloadAndOpenReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports'), centerTitle: true),
      body: BlocConsumer<ReportCubit, ReportState>(
        listener: (context, state) {
          if (state.isDownloaded && state.filePath != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report downloaded successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildReportCard(context, state),
                  const Spacer(),
                  _buildInfoText(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.description_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Department Reports',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Download and view organizational reports',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, ReportState state) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department Employee Report',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete list of all employees by department',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStateContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, ReportState state) {
    return switch (state.status) {
      ReportStatus.initial => _buildDownloadButton(context),
      ReportStatus.downloading => _buildDownloadingIndicator(context),
      ReportStatus.downloaded => _buildDownloadedContent(context, state),
      ReportStatus.error => _buildErrorContent(context, state),
    };
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: () => _onDownloadPressed(context),
        icon: const Icon(Icons.download),
        label: const Text(
          'Download Report',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDownloadingIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 12),
        Text(
          'Downloading report...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadedContent(BuildContext context, ReportState state) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Text(
              'Report downloaded successfully',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<ReportCubit>().openReport();
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Again'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _onRetry(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Download New'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, ReportState state) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.errorMessage ?? 'Failed to download report',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () => _onRetry(context),
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Try Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Reports are generated as PDF files and will open in your device\'s default PDF viewer.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
