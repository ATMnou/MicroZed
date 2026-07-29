/// 마이페이지 > 로컬 LLM 화면에서 원탭으로 받을 수 있는 추천 모델 목록.
/// source는 llamadart의 `hf://owner/repo/file.gguf` 형식이며, 실제 다운로드/캐시는
/// llamadart가 알아서 처리한다(재실행 시 캐시 재사용).
class LocalModelCatalogEntry {
  const LocalModelCatalogEntry({
    required this.id,
    required this.label,
    required this.description,
    required this.source,
    required this.approxSizeMb,
  });

  final String id;
  final String label;
  final String description;
  final String source;
  final int approxSizeMb;
}

// Huihui(huihui.ai)의 abliterated(검열 완화) 시리즈 위주로 구성했다. 롤플레잉/캐릭터 채팅에서
// 원작 모델보다 거절 응답이 적어 이 앱 용도에 더 잘 맞는다.
const List<LocalModelCatalogEntry> kLocalModelCatalog = [
  LocalModelCatalogEntry(
    id: 'huihui-gemma4-e2b',
    label: 'Huihui Gemma 4 E2B Abliterated',
    description: '가장 가볍고 빠름. 검열 완화(abliterated) 버전. 저사양 기기에 적합.',
    source:
        'hf://huihui-ai/Huihui-gemma-4-E2B-it-qat-q4_0-unquantized-abliterated-GGUF/'
        'Huihui-gemma-4-E2B-it-qat-q4_0-unquantized-abliterated-Q4_K.gguf',
    approxSizeMb: 3260,
  ),
  LocalModelCatalogEntry(
    id: 'huihui-qwen35-4b',
    label: 'Huihui Qwen3.5 4B Abliterated',
    description: '속도와 품질의 균형. 검열 완화 버전. 한국어 대응이 비교적 좋음.',
    source: 'hf://mradermacher/Huihui-Qwen3.5-4B-abliterated-GGUF/'
        'Huihui-Qwen3.5-4B-abliterated.Q4_K_M.gguf',
    approxSizeMb: 2580,
  ),
  LocalModelCatalogEntry(
    id: 'huihui-gemma4-e4b',
    label: 'Huihui Gemma 4 E4B Abliterated',
    description: '더 나은 품질. 검열 완화 버전. 고사양 기기/PC 권장.',
    source:
        'hf://huihui-ai/Huihui-gemma-4-E4B-it-qat-q4_0-unquantized-abliterated-GGUF/'
        'Huihui-gemma-4-E4B-it-qat-q4_0-unquantized-abliterated-Q4_K.gguf',
    approxSizeMb: 5060,
  ),
];
