// LIMYÈ component catalog: 51 industry + 16 LIMYÈ-unique = 67 components.
// Styling is never specified per-component; the host app theme binds visuals.

class ComponentCatalog {
  ComponentCatalog._();

  /// Full catalog schema for AI / org tooling (runtime map).
  static final Map<String, dynamic> catalogSchema =
      Map<String, dynamic>.unmodifiable({
    'version': '1.0.0',
    'brand': 'LIMYÈ',
    'notes':
        'Prop types use JSON Schema-style names. Children lists name allowed child component types.',
    'components': List<Map<String, dynamic>>.unmodifiable(_components()),
  });

  static Map<String, dynamic> _p(String name, String type, [Object? defaultVal]) =>
      {'name': name, 'type': type, 'default': defaultVal};

  static List<String> _ctx(
    List<String> base,
  ) =>
      List<String>.unmodifiable(base);

  static const _allSurfaces = <String>[
    'dashboard',
    'crm',
    'drawer',
    'modal',
    'sheet',
    'settings',
    'mobile',
    'intake',
    'pipeline',
    'flow_mesh',
    'platform_builder',
  ];

  static Map<String, dynamic> _entry({
    required String type,
    required String category,
    required List<Map<String, dynamic>> props,
    required List<String> children,
    Map<String, Object?> constraints = const {},
    List<String>? allowedIn,
  }) =>
      {
        'type': type,
        'category': category,
        'props': props,
        'children': children,
        'constraints': constraints,
        'allowed_in': allowedIn ?? _ctx(_allSurfaces),
      };

  static List<(String, List<Map<String, dynamic>>)> get _customFieldSpecs => [
        ('Text', [
          _p('max_length', 'integer', 255),
          _p('multiline', 'boolean', false),
        ]),
        ('Number', [
          _p('min', 'number', null),
          _p('max', 'number', null),
        ]),
        ('Date', [
          _p('include_time', 'boolean', false),
        ]),
        ('Dropdown', [
          _p('options', 'array', <dynamic>[]),
        ]),
        ('MultiSelect', [
          _p('options', 'array', <dynamic>[]),
          _p('max_selected', 'integer', 10),
        ]),
        ('File', [
          _p('max_mb', 'number', 25),
        ]),
        ('Photo', [
          _p('max_mb', 'number', 12),
        ]),
        ('Toggle', [
          _p('default_value', 'boolean', false),
        ]),
        ('URL', [
          _p('validate_https', 'boolean', true),
        ]),
        ('Phone', [
          _p('default_country', 'string', 'US'),
        ]),
        ('Email', [
          _p('allow_plus', 'boolean', true),
        ]),
        ('Currency', [
          _p('iso_code', 'string', 'USD'),
        ]),
        ('Formula', [
          _p('expression', 'string', ''),
          _p('depends_on', 'array', <dynamic>[]),
        ]),
      ];

  static List<Map<String, dynamic>> _components() {
    final out = <Map<String, dynamic>>[
      _entry(
        type: 'ContactCard',
        category: 'crm',
        props: [
          _p('record_id', 'string', ''),
          _p('full_name', 'string', ''),
          _p('subtitle', 'string', ''),
          _p('avatar_url', 'string', ''),
        ],
        children: ['QuickActionsMenu', 'CustomFieldText'],
        constraints: {'min_width': 280.0},
      ),
      _entry(
        type: 'CompanyCard',
        category: 'crm',
        props: [
          _p('company_id', 'string', ''),
          _p('name', 'string', ''),
          _p('industry', 'string', ''),
        ],
        children: ['DealCard', 'ContactCard'],
        constraints: {'min_width': 320.0},
      ),
      _entry(
        type: 'DealCard',
        category: 'crm',
        props: [
          _p('deal_id', 'string', ''),
          _p('title', 'string', ''),
          _p('stage_id', 'string', ''),
          _p('amount', 'number', 0),
        ],
        children: ['CustomFieldCurrency', 'ActivityTimeline'],
        constraints: {'min_width': 260.0},
      ),
      _entry(
        type: 'PipelineBoard',
        category: 'crm',
        props: [
          _p('pipeline_id', 'string', ''),
          _p('title', 'string', 'Pipeline'),
        ],
        children: ['PipelineStageColumn'],
        constraints: {'min_height': 400.0},
        allowedIn: _ctx(['crm', 'dashboard', 'mobile']),
      ),
      _entry(
        type: 'PipelineStageColumn',
        category: 'crm',
        props: [
          _p('stage_id', 'string', ''),
          _p('title', 'string', ''),
          _p('wip_limit', 'integer', 0),
        ],
        children: ['DealCard'],
        constraints: {'min_width': 260.0},
        allowedIn: _ctx(['crm', 'dashboard', 'pipeline']),
      ),
      _entry(
        type: 'ActivityTimeline',
        category: 'crm',
        props: [
          _p('subject_id', 'string', ''),
          _p('subject_type', 'string', 'lead'),
          _p('page_size', 'integer', 25),
        ],
        children: const [],
        constraints: {'min_height': 200.0},
      ),
      _entry(
        type: 'ActivityScheduler',
        category: 'crm',
        props: [
          _p('owner_id', 'string', ''),
          _p('timezone', 'string', 'UTC'),
        ],
        children: const [],
        constraints: {},
        allowedIn: _ctx(['crm', 'drawer', 'modal']),
      ),
      _entry(
        type: 'LeadInbox',
        category: 'crm',
        props: [
          _p('queue_id', 'string', ''),
          _p('autoreply', 'boolean', false),
        ],
        children: ['DealCard', 'ContactCard'],
      ),
      _entry(
        type: 'LeadScoringWidget',
        category: 'crm',
        props: [
          _p('lead_id', 'string', ''),
          _p('model_id', 'string', 'default'),
        ],
        children: const [],
      ),
      _entry(
        type: 'EmailIntegrationPanel',
        category: 'integrations',
        props: [
          _p('mailbox_id', 'string', ''),
          _p('sync_folders', 'array', const []),
        ],
        children: const [],
        allowedIn: _ctx(['settings', 'drawer', 'modal']),
      ),
      _entry(
        type: 'CallDialerWidget',
        category: 'communications',
        props: [
          _p('default_caller_id', 'string', ''),
          _p('record_calls', 'boolean', false),
        ],
        children: const [],
      ),
      for (final spec in _customFieldSpecs)
        _entry(
          type: 'CustomField${spec.$1}',
          category: 'fields',
          props: [
            _p('field_key', 'string', ''),
            _p('label', 'string', ''),
            _p('required', 'boolean', false),
            _p('help_text', 'string', ''),
            ...spec.$2,
          ],
          children: const [],
          constraints: {'max_instances_per_form': 64},
        ),
      _entry(
        type: 'CustomModule',
        category: 'platform',
        props: [
          _p('module_id', 'string', ''),
          _p('title', 'string', ''),
          _p('route', 'string', ''),
        ],
        children: ['DashboardMetricsGrid', 'DataTable', 'FormBuilder'],
      ),
      _entry(
        type: 'FormBuilder',
        category: 'forms',
        props: [
          _p('form_id', 'string', ''),
          _p('submit_endpoint', 'string', ''),
        ],
        children: [
          'CustomFieldText',
          'CustomFieldNumber',
          'CustomFieldDate',
          'CustomFieldDropdown',
          'CustomFieldToggle',
        ],
      ),
      _entry(
        type: 'IntakeForm',
        category: 'intake',
        props: [
          _p('intake_id', 'string', ''),
          _p('project_type', 'string', 'residential'),
        ],
        children: ['FormBuilder', 'CustomFieldText'],
        allowedIn: _ctx(['intake', 'mobile', 'drawer']),
      ),
      _entry(
        type: 'DashboardMetricsGrid',
        category: 'analytics',
        props: [
          _p('dashboard_id', 'string', ''),
          _p('columns', 'integer', 3),
        ],
        children: ['CardGridView'],
      ),
      _entry(
        type: 'RevenueChart',
        category: 'analytics',
        props: [
          _p('time_range', 'string', '30d'),
          _p('currency', 'string', 'USD'),
        ],
        children: const [],
      ),
      _entry(
        type: 'PipelineFunnelChart',
        category: 'analytics',
        props: [
          _p('pipeline_id', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'ForecastTable',
        category: 'analytics',
        props: [
          _p('scenario_id', 'string', 'base'),
        ],
        children: const [],
      ),
      _entry(
        type: 'DataTable',
        category: 'data',
        props: [
          _p('dataset_id', 'string', ''),
          _p('page_size', 'integer', 50),
          _p('sortable', 'boolean', true),
        ],
        children: const [],
      ),
      _entry(
        type: 'ListView',
        category: 'layout',
        props: [
          _p('item_template_id', 'string', ''),
        ],
        children: ['ContactCard', 'DealCard', 'UserProfileCard'],
      ),
      _entry(
        type: 'CardGridView',
        category: 'layout',
        props: [
          _p('columns', 'integer', 2),
        ],
        children: ['CompanyCard', 'DealCard'],
      ),
      _entry(
        type: 'CalendarView',
        category: 'scheduling',
        props: [
          _p('calendar_id', 'string', ''),
          _p('view', 'string', 'month'),
        ],
        children: ['ActivityScheduler'],
      ),
      _entry(
        type: 'TimelineGanttView',
        category: 'scheduling',
        props: [
          _p('project_id', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'SearchBar',
        category: 'navigation',
        props: [
          _p('placeholder', 'string', 'Search…'),
          _p('scope', 'string', 'global'),
        ],
        children: const [],
      ),
      _entry(
        type: 'FilterPanel',
        category: 'navigation',
        props: [
          _p('saved_view_id', 'string', ''),
        ],
        children: ['CustomFieldDropdown', 'CustomFieldDate'],
      ),
      _entry(
        type: 'SegmentsTool',
        category: 'marketing',
        props: [
          _p('segment_id', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'QuickActionsMenu',
        category: 'navigation',
        props: [
          _p('context_id', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'NotificationCenter',
        category: 'system',
        props: [
          _p('user_id', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'WorkflowAutomationRule',
        category: 'automation',
        props: [
          _p('rule_id', 'string', ''),
          _p('enabled', 'boolean', true),
        ],
        children: const [],
      ),
      _entry(
        type: 'BlueprintBuilder',
        category: 'platform',
        props: [
          _p('blueprint_id', 'string', ''),
        ],
        children: ['WorkflowAutomationRule', 'CustomModule'],
        allowedIn: _ctx(['platform_builder', 'settings']),
      ),
      _entry(
        type: 'RolePermissionManager',
        category: 'security',
        props: [
          _p('org_id', 'string', ''),
        ],
        children: const [],
        allowedIn: _ctx(['settings', 'drawer', 'modal']),
      ),
      _entry(
        type: 'APIKeyManager',
        category: 'integrations',
        props: [
          _p('rotation_days', 'integer', 90),
        ],
        children: const [],
        allowedIn: _ctx(['settings', 'integrations']),
      ),
      _entry(
        type: 'WebhookConfigurationPanel',
        category: 'integrations',
        props: [
          _p('endpoint_url', 'string', ''),
          _p('secret_env', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'IntegrationMarketplace',
        category: 'integrations',
        props: [
          _p('category_filter', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'MobileResponsiveShell',
        category: 'layout',
        props: [
          _p('breakpoint_sm', 'integer', 600),
        ],
        children: ['ListView', 'NotificationCenter', 'QuickActionsMenu'],
        allowedIn: _ctx(['mobile', 'dashboard']),
      ),
      _entry(
        type: 'UserProfileCard',
        category: 'identity',
        props: [
          _p('user_id', 'string', ''),
          _p('show_roles', 'boolean', true),
        ],
        children: const [],
      ),
      _entry(
        type: 'BillingPlanManager',
        category: 'billing',
        props: [
          _p('subscription_id', 'string', ''),
          _p('billing_email', 'string', ''),
        ],
        children: const [],
        allowedIn: _ctx(['settings', 'drawer', 'modal']),
      ),
      _entry(
        type: 'AIChatAssistantPanel',
        category: 'ai',
        props: [
          _p('session_id', 'string', ''),
          _p('model', 'string', 'default'),
        ],
        children: ['PromptToInterfaceBox'],
        allowedIn: _ctx(['dashboard', 'crm', 'drawer', 'platform_builder']),
      ),
      // —— LIMYÈ-unique (16) ——
      _entry(
        type: 'AISolarDesignSummaryCard',
        category: 'limye_solar',
        props: [
          _p('design_id', 'string', ''),
          _p('system_kw', 'number', 0),
          _p('annual_kwh', 'number', 0),
        ],
        children: ['RoofAnalysisViewer'],
        allowedIn: _ctx(['dashboard', 'mobile', 'intake']),
      ),
      _entry(
        type: 'RoofAnalysisViewer',
        category: 'limye_solar',
        props: [
          _p('site_id', 'string', ''),
          _p('imagery_source', 'string', 'satellite'),
        ],
        children: const [],
      ),
      _entry(
        type: 'PermitReadyPlanSetGenerator',
        category: 'limye_solar',
        props: [
          _p('jurisdiction', 'string', ''),
          _p('ahj_code', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'FinancialSavingsProjectionCard',
        category: 'limye_finance',
        props: [
          _p('tariff_id', 'string', ''),
          _p('years', 'integer', 25),
        ],
        children: const [],
      ),
      _entry(
        type: 'InstallerMatchingCard',
        category: 'limye_network',
        props: [
          _p('zip', 'string', ''),
          _p('radius_miles', 'number', 50),
        ],
        children: const [],
      ),
      _entry(
        type: 'FinancingOfferCard',
        category: 'limye_finance',
        props: [
          _p('offer_id', 'string', ''),
          _p('apr', 'number', 0),
        ],
        children: const [],
      ),
      _entry(
        type: 'CommunityPoolInvestmentCard',
        category: 'limye_pool',
        props: [
          _p('pool_id', 'string', ''),
          _p('min_amount', 'number', 0),
        ],
        children: const [],
      ),
      _entry(
        type: 'DroneOpJobCard',
        category: 'limye_drone',
        props: [
          _p('mission_id', 'string', ''),
          _p('status', 'string', 'open'),
        ],
        children: const [],
        allowedIn: _ctx(['mobile', 'dashboard', 'crm']),
      ),
      _entry(
        type: 'HLIOWalletBalanceChip',
        category: 'limye_token',
        props: [
          _p('wallet_address', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'AISalesCoachPanel',
        category: 'limye_ai',
        props: [
          _p('playbook_id', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'AutoDispositioningRuleCard',
        category: 'limye_automation',
        props: [
          _p('rule_name', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'AIGeneratedCallSummaryCard',
        category: 'limye_ai',
        props: [
          _p('call_id', 'string', ''),
        ],
        children: const [],
      ),
      _entry(
        type: 'PromptToInterfaceBox',
        category: 'limye_platform',
        props: [
          _p('surface_binding', 'string', 'limye-main'),
        ],
        children: const [],
        allowedIn: _ctx(['platform_builder', 'drawer', 'modal']),
      ),
      _entry(
        type: 'FlowMeshNodeGraphEditor',
        category: 'limye_flow',
        props: [
          _p('pipeline_id', 'string', ''),
        ],
        children: const [],
        allowedIn: _ctx(['flow_mesh', 'settings', 'platform_builder']),
      ),
      _entry(
        type: 'CustomComponentBuilder',
        category: 'limye_platform',
        props: [
          _p('draft_id', 'string', ''),
        ],
        children: ['CustomComponentLibrary'],
        allowedIn: _ctx(['platform_builder', 'settings']),
      ),
      _entry(
        type: 'CustomComponentLibrary',
        category: 'limye_platform',
        props: [
          _p('org_id', 'string', ''),
        ],
        children: const [],
        allowedIn: _ctx(['platform_builder', 'settings']),
      ),
    ];
    assert(out.length == 67, 'Expected 67 components, got ${out.length}');
    return out;
  }
}
