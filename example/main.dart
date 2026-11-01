// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_pardot/otel_pardot.dart';

/// Traces Pardot / Account Engagement v5 calls with OpenTelemetry.
///
/// `otel_pardot` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Pardot / Account Engagement v5 call in
/// [tracedPardot]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'pardot-example');

  // Wraps a Pardot / Account Engagement v5 API call in a CLIENT span.
  final pardotId = await tracedPardot<String>(
    operation: 'prospects.create',
    invoke: () async {
      // Make the Pardot / Account Engagement v5 call here, then report what it returned.
      const id = 'pardot_8f3a2c';
      return const PardotCallResult(
          value: id,
          result: PardotResult(
              businessUnitId: 'businessunit_8f3a2c',
              objectKind: 'prospect',
              objectId: 'object_8f3a2c',
              action: 'create',
              prospectGrade: 'A+',
              prospectScore: 1,
              listEmailId: 'listemail_8f3a2c',
              deliveredCount: 3,
              openCount: 3,
              clickCount: 3,
              bouncedCount: 3,
              unsubscribedCount: 3,
              formId: 'form_8f3a2c',
              formSubmissions: 120,
              campaignId: 'campaign_8f3a2c',
              engagementProgram: 'example',
              engagementStep: 'example',
              dailyApiCallsUsed: 1,
              dailyApiCallsLimit: 25,
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedPardot prospects.create returned $pardotId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutPardotInstrumentationAsync.
  await runWithoutPardotInstrumentationAsync(
    () => tracedPardot<String>(
      operation: 'prospects.create',
      invoke: () async {
        const id = 'pardot_8f3a2c';
        return const PardotCallResult(
            value: id,
            result: PardotResult(
                businessUnitId: 'businessunit_8f3a2c',
                objectKind: 'prospect',
                objectId: 'object_8f3a2c',
                action: 'create',
                prospectGrade: 'A+',
                prospectScore: 1,
                listEmailId: 'listemail_8f3a2c',
                deliveredCount: 3,
                openCount: 3,
                clickCount: 3,
                bouncedCount: 3,
                unsubscribedCount: 3,
                formId: 'form_8f3a2c',
                formSubmissions: 120,
                campaignId: 'campaign_8f3a2c',
                engagementProgram: 'example',
                engagementStep: 'example',
                dailyApiCallsUsed: 1,
                dailyApiCallsLimit: 25,
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
