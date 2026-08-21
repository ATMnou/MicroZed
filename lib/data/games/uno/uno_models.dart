enum UnoColor { red, yellow, green, blue, wild }

enum UnoValue {
  n0, n1, n2, n3, n4, n5, n6, n7, n8, n9,
  skip, reverse, drawTwo,
  wild, wildDrawFour,
}

bool unoValueIsNumber(UnoValue v) => v.index <= UnoValue.n9.index;

int? unoValueNumber(UnoValue v) => unoValueIsNumber(v) ? v.index : null;

bool unoValueIsWild(UnoValue v) => v == UnoValue.wild || v == UnoValue.wildDrawFour;

class UnoCard {
  const UnoCard({required this.color, required this.value});

  /// 와일드 카드는 [UnoColor.wild]로 시작하지만, 실제로 낸 뒤에는 플레이어가 고른 색으로
  /// 판 위에서 다뤄야 하므로 [UnoEngine]이 별도로 currentColor를 관리한다.
  final UnoColor color;
  final UnoValue value;

  String get label {
    if (unoValueIsNumber(value)) return '${unoValueNumber(value)}';
    return switch (value) {
      UnoValue.skip => '⊘',
      UnoValue.reverse => '⇄',
      UnoValue.drawTwo => '+2',
      UnoValue.wild => '★',
      UnoValue.wildDrawFour => '+4★',
      _ => '',
    };
  }
}
