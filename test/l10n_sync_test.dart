import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// l10n ARB 파일 키 동기화 검증 테스트
/// 모든 언어 파일이 동일한 키를 가지고 있는지 확인
void main() {
  group('l10n 키 동기화', () {
    late Map<String, dynamic> koArb;
    late Map<String, dynamic> enArb;
    late Map<String, dynamic> jaArb;
    late Map<String, dynamic> zhArb;

    setUp(() {
      koArb = _loadArb('lib/l10n/app_ko.arb');
      enArb = _loadArb('lib/l10n/app_en.arb');
      jaArb = _loadArb('lib/l10n/app_ja.arb');
      zhArb = _loadArb('lib/l10n/app_zh.arb');
    });

    test('ko 템플릿의 모든 키가 en에 존재', () {
      final missing = _findMissingKeys(koArb, enArb);
      expect(missing, isEmpty, reason: 'en에 누락된 키: $missing');
    });

    test('ko 템플릿의 모든 키가 ja에 존재', () {
      final missing = _findMissingKeys(koArb, jaArb);
      expect(missing, isEmpty, reason: 'ja에 누락된 키: $missing');
    });

    test('ko 템플릿의 모든 키가 zh에 존재', () {
      final missing = _findMissingKeys(koArb, zhArb);
      expect(missing, isEmpty, reason: 'zh에 누락된 키: $missing');
    });

    test('en에 ko에 없는 키가 없음', () {
      final extra = _findMissingKeys(enArb, koArb);
      expect(extra, isEmpty, reason: 'en에만 있는 키: $extra');
    });

    test('모든 값이 비어있지 않음', () {
      for (final entry in {'ko': koArb, 'en': enArb, 'ja': jaArb, 'zh': zhArb}.entries) {
        for (final key in _userKeys(entry.value)) {
          final value = entry.value[key] as String;
          expect(value.trim().isNotEmpty, isTrue,
              reason: '${entry.key}.$key 값이 비어있음');
        }
      }
    });
  });
}

Map<String, dynamic> _loadArb(String path) {
  final file = File(path);
  return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
}

/// @로 시작하는 메타데이터 키와 @@locale을 제외한 사용자 키 목록
List<String> _userKeys(Map<String, dynamic> arb) {
  return arb.keys
      .where((k) => !k.startsWith('@'))
      .toList();
}

/// source에는 있지만 target에 없는 사용자 키
List<String> _findMissingKeys(Map<String, dynamic> source, Map<String, dynamic> target) {
  final sourceKeys = _userKeys(source);
  final targetKeys = _userKeys(target).toSet();
  return sourceKeys.where((k) => !targetKeys.contains(k)).toList();
}
