// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_pardot/otel_pardot.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_pardot-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('prospects.update records grade + score + quota', () async {
    await tracedPardot<String>(
      operation: 'prospects.update',
      invoke: () async => const PardotCallResult(
        value: 'ok',
        result: PardotResult(
          businessUnitId: '0Uvabc',
          objectKind: 'prospect',
          objectId: '12345',
          action: 'update',
          prospectGrade: 'A',
          prospectScore: 240,
          dailyApiCallsUsed: 1200,
          dailyApiCallsLimit: 25000,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('pardot prospects.update')!);
    expect(a['pardot.prospect.grade'], 'A');
    expect(a['pardot.prospect.score'], 240);
  });

  test('listEmails.send records delivery counts', () async {
    await tracedPardot<String>(
      operation: 'listEmails.send',
      invoke: () async => const PardotCallResult(
        value: 'ok',
        result: PardotResult(
          objectKind: 'list_email',
          listEmailId: 'le_1',
          deliveredCount: 4800,
          openCount: 1200,
          clickCount: 300,
          bouncedCount: 50,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('pardot listEmails.send')!);
    expect(a['pardot.email.delivered_count'], 4800);
    expect(a['pardot.email.bounced_count'], 50);
  });

  test('daily api limit error sets span error', () async {
    await tracedPardot<String>(
      operation: 'prospects.query',
      invoke: () async => const PardotCallResult(
        value: 'ok',
        result: PardotResult(
          errorCode: '15',
          errorMessage: 'Daily API call limit exceeded',
          statusCode: 429,
        ),
      ),
    );
    expect(
      spans.findSpanByName('pardot prospects.query')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutPardotInstrumentationAsync(() async {
      await tracedPardot<String>(
        operation: 'oauth.token',
        invoke: () async => const PardotCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('pardot '), isEmpty);
  });
}
