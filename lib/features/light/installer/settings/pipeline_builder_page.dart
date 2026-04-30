import 'package:blacklight_app/features/light/installer/settings/pipeline_builder_canvas.dart';
import 'package:flutter/material.dart';

class PipelineBuilderPage extends StatelessWidget {
  const PipelineBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PipelineBuilderCanvas(pipelineId: 'local-empty-canvas');
  }
}
