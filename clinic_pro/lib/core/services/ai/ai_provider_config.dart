// ────────────────────────────────────────────────────────
// AiProviderConfig — تكوين مزودي الذكاء الاصطناعي والموديلات الافتراضية
// ────────────────────────────────────────────────────────

enum AiProviderType {
  openai,
  claude,
  gemini,
  deepseek,
  groq,
  qwen,
  gimi,
  custom,
}

class AiModelInfo {
  final String id;
  final String displayName;
  final String? description;
  final bool isRecommended;

  const AiModelInfo({
    required this.id,
    required this.displayName,
    this.description,
    this.isRecommended = false,
  });
}

class AiProviderConfig {
  AiProviderConfig._();

  static AiProviderType parseType(String? name) {
    if (name == null) return AiProviderType.openai;
    return AiProviderType.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase(),
      orElse: () => AiProviderType.openai,
    );
  }

  static String displayName(AiProviderType type) => switch (type) {
        AiProviderType.openai => 'OpenAI (ChatGPT)',
        AiProviderType.claude => 'Anthropic (Claude)',
        AiProviderType.gemini => 'Google (Gemini)',
        AiProviderType.deepseek => 'DeepSeek',
        AiProviderType.groq => 'Groq (فائق السرعة)',
        AiProviderType.qwen => 'Alibaba (Qwen)',
        AiProviderType.gimi => 'Gimi AI',
        AiProviderType.custom => 'مخصص (Custom Base URL)',
      };

  static String defaultBaseUrl(AiProviderType type) => switch (type) {
        AiProviderType.openai => 'https://api.openai.com/v1',
        AiProviderType.claude => 'https://api.anthropic.com/v1',
        AiProviderType.gemini =>
          'https://generativelanguage.googleapis.com/v1beta/openai',
        AiProviderType.deepseek => 'https://api.deepseek.com/v1',
        AiProviderType.groq => 'https://api.groq.com/openai/v1',
        AiProviderType.qwen =>
          'https://dashscope-intl.aliyuncs.com/compatible-mode/v1',
        AiProviderType.gimi => 'https://api.gimi.app/v1',
        AiProviderType.custom => '',
      };

  static bool supportsModelFetching(AiProviderType type) => switch (type) {
        AiProviderType.claude => false,
        _ => true,
      };

  /// قائمة الموديلات الافتراضية لكل مزود (مُرتبة من الأقوى للأضعف)
  static List<AiModelInfo> defaultModels(AiProviderType type) => switch (type) {
        AiProviderType.openai => const [
            AiModelInfo(
              id: 'gpt-4o',
              displayName: 'GPT-4o',
              description: 'الأقوى والأذكى في الفهم والتحليل الطبي',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'gpt-4o-mini',
              displayName: 'GPT-4o-mini',
              description: 'سريع واقتصادي جداً ودقيق في استخراج البيانات',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'gpt-4-turbo',
              displayName: 'GPT-4 Turbo',
              description: 'قوي وشامل',
            ),
            AiModelInfo(
              id: 'gpt-3.5-turbo',
              displayName: 'GPT-3.5 Turbo',
              description: 'موديل اقتصادي قديم',
            ),
          ],
        AiProviderType.claude => const [
            AiModelInfo(
              id: 'claude-3-5-sonnet-20241022',
              displayName: 'Claude 3.5 Sonnet',
              description: 'الأقوى في استيعاب التراكيب اللغوية المعقدة',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'claude-3-5-haiku-20241022',
              displayName: 'Claude 3.5 Haiku',
              description: 'فائق السرعة واقتصادي',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'claude-3-opus-20240229',
              displayName: 'Claude 3 Opus',
              description: 'ذو قدرات تحليلية متقدمة جداً',
            ),
          ],
        AiProviderType.gemini => const [
            AiModelInfo(
              id: 'gemini-2.0-flash',
              displayName: 'Gemini 2.0 Flash',
              description: 'الجيل الأحدث فائق السرعة والأداء',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'gemini-1.5-pro',
              displayName: 'Gemini 1.5 Pro',
              description: 'الأقوى في سياقات النصوص الطويلة والتشخيصات',
            ),
            AiModelInfo(
              id: 'gemini-1.5-flash',
              displayName: 'Gemini 1.5 Flash',
              description: 'سريع ومناسب للاستخراج الفوري',
            ),
          ],
        AiProviderType.deepseek => const [
            AiModelInfo(
              id: 'deepseek-chat',
              displayName: 'DeepSeek Chat (V3)',
              description: 'قوي جداً في فهم السياق واقتصادي للغاية',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'deepseek-reasoner',
              displayName: 'DeepSeek Reasoner (R1)',
              description: 'قائم على التفكير المنطقي العميق',
            ),
          ],
        AiProviderType.groq => const [
            AiModelInfo(
              id: 'llama-3.3-70b-versatile',
              displayName: 'Llama 3.3 70B (Groq)',
              description: 'أقوى موديل مفتوح المصدر بسرعة استجابة خارقة',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'llama-3.1-8b-instant',
              displayName: 'Llama 3.1 8B (Groq)',
              description: 'سرعة البرق للاستخراج اللحظي',
            ),
            AiModelInfo(
              id: 'mixtral-8x7b-32768',
              displayName: 'Mixtral 8x7B',
              description: 'أداء متميز في التراكيب المتعددة',
            ),
          ],
        AiProviderType.qwen => const [
            AiModelInfo(
              id: 'qwen-plus',
              displayName: 'Qwen Plus',
              description: 'أداء ممتاز ودعم قوي للغات متعددة',
              isRecommended: true,
            ),
            AiModelInfo(
              id: 'qwen-turbo',
              displayName: 'Qwen Turbo',
              description: 'سريع واقتصادي',
            ),
            AiModelInfo(
              id: 'qwen-max',
              displayName: 'Qwen Max',
              description: 'الأقوى والأكثر تطوراً من علي بابا',
            ),
          ],
        AiProviderType.gimi => const [
            AiModelInfo(
              id: 'gimi-v1',
              displayName: 'Gimi V1',
              description: 'موديل Gimi الذكي',
              isRecommended: true,
            ),
          ],
        AiProviderType.custom => const [],
      };
}
