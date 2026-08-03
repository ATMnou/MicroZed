/// 마이페이지 > 로컬 LLM 화면에서 원탭으로 받을 수 있는 추천 모델 목록.
/// source는 llamadart의 `hf://owner/repo/file.gguf` 형식이며, 실제 다운로드/캐시는
/// llamadart가 알아서 처리한다(재실행 시 캐시 재사용).
class LocalModelCatalogEntry {
  const LocalModelCatalogEntry({
    required this.id,
    required this.label,
    required this.source,
    required this.approxSizeMb,
  });

  final String id;
  final String label;

  /// 설명 문구는 다국어 지원을 위해 여기 담지 않는다. 화면에서 [id] 기준으로
  /// `AppLocalizations.localLlmModelDesc*` 키를 조회해서 써야 한다.
  final String source;
  final int approxSizeMb;
}

// Huihui(huihui.ai)의 abliterated(검열 완화) 시리즈 위주로 구성했다. 롤플레잉/캐릭터 채팅에서
// 원작 모델보다 거절 응답이 적어 이 앱 용도에 더 잘 맞는다.
const List<LocalModelCatalogEntry> kLocalModelCatalog = [
  LocalModelCatalogEntry(
    id: 'huihui-qwen3.5-08b',
    label: 'Huihui Qwen 3.5 0.8B Abliterated',
    source:
        'hf://mradermacher/Huihui-Qwen3.5-0.8B-abliterated-GGUF/'
        'Huihui-Qwen3.5-0.8B-abliterated.IQ4_XS.gguf',
    approxSizeMb: 490,
  ),
  LocalModelCatalogEntry(
    id: 'huihui-qwen35-4b',
    label: 'Huihui Qwen3.5 4B Abliterated',
    source:
        'hf://mradermacher/Huihui-Qwen3.5-4B-abliterated-GGUF/'
        'Huihui-Qwen3.5-4B-abliterated.Q4_K_M.gguf',
    approxSizeMb: 2580,
  ),
  LocalModelCatalogEntry(
    id: 'huihui-gemma4-e2b',
    label: 'Huihui Gemma 4 E2B Abliterated',
    source:
        'hf://huihui-ai/Huihui-gemma-4-E2B-it-qat-q4_0-unquantized-abliterated-GGUF/'
        'Huihui-gemma-4-E2B-it-qat-q4_0-unquantized-abliterated-Q4_K.gguf',
    approxSizeMb: 3260,
  ),
  LocalModelCatalogEntry(
    id: 'huihui-gemma4-e4b',
    label: 'Huihui Gemma 4 E4B Abliterated',
    source:
        'hf://huihui-ai/Huihui-gemma-4-E4B-it-qat-q4_0-unquantized-abliterated-GGUF/'
        'Huihui-gemma-4-E4B-it-qat-q4_0-unquantized-abliterated-Q4_K.gguf',
    approxSizeMb: 5060,
  ),
];
