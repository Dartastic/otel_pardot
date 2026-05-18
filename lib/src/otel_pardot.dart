// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_pardot_suppression.dart';

const _tracerName = 'dartastic_otel_libs_pardot';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class PardotResult {
  const PardotResult({
    this.businessUnitId,
    this.objectKind,
    this.objectId,
    this.action,
    this.prospectGrade,
    this.prospectScore,
    this.listEmailId,
    this.deliveredCount,
    this.openCount,
    this.clickCount,
    this.bouncedCount,
    this.unsubscribedCount,
    this.formId,
    this.formSubmissions,
    this.campaignId,
    this.engagementProgram,
    this.engagementStep,
    this.dailyApiCallsUsed,
    this.dailyApiCallsLimit,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// Salesforce business unit id (`0Uv...`).
  final String? businessUnitId;

  /// `prospect`, `account`, `opportunity`, `campaign`, `list`,
  /// `list_email`, `list_membership`, `email`, `email_template`,
  /// `engagement_program`, `engagement_step`, `engagement_event`,
  /// `form`, `form_handler`, `tracker`, `dynamic_content`, `file`,
  /// `landing_page`, `tag`, `tagObject`, `user`, `visitor`,
  /// `visitor_activity`, `visit`, `lifecycle_history`,
  /// `lifecycle_stage`, `field`, `external_activity`.
  final String? objectKind;
  final String? objectId;

  /// `create`, `read`, `update`, `upsert`, `delete`, `query`,
  /// `assign_to_user`, `unassign`, `email.send`,
  /// `engagement.start`, `engagement.pause`, `engagement.resume`.
  final String? action;

  /// Prospect grade `A+`, `A`, `B`, `C`, `D`, `F`.
  final String? prospectGrade;

  /// Prospect score (Salesforce numeric).
  final int? prospectScore;

  /// List email send id.
  final String? listEmailId;

  final int? deliveredCount;
  final int? openCount;
  final int? clickCount;
  final int? bouncedCount;
  final int? unsubscribedCount;

  final String? formId;
  final int? formSubmissions;

  final String? campaignId;
  final String? engagementProgram;
  final String? engagementStep;

  /// Pardot enforces a daily API call cap per business unit.
  final int? dailyApiCallsUsed;
  final int? dailyApiCallsLimit;

  /// Pardot error code (1 invalid api key, 4 invalid api version,
  /// 15 daily api limit exceeded, 17 access denied, 35 server error,
  /// 50 missing required parameter, 51 invalid id, 53 access not allowed,
  /// 121 invalid prospect status, 124 invalid permissions, 184 sso required).
  final String? errorCode;
  final String? errorMessage;

  final int? statusCode;
}

class PardotCallResult<T> {
  const PardotCallResult({required this.value, this.result});
  final T value;
  final PardotResult? result;
}

/// Wraps a Pardot / Account Engagement v5 API call in a CLIENT span.
/// [operation] is one of `prospects.create`, `prospects.read`,
/// `prospects.update`, `prospects.upsert`, `prospects.query`,
/// `prospects.delete`, `prospects.assign`, `prospects.unassign`,
/// `accounts.create`, `accounts.update`, `accounts.query`,
/// `opportunities.create`, `opportunities.update`, `opportunities.delete`,
/// `lists.create`, `lists.update`, `lists.delete`,
/// `listMemberships.create`, `listMemberships.delete`,
/// `listMemberships.query`, `listEmails.create`,
/// `listEmails.send`, `listEmails.read`, `listEmails.query`,
/// `emails.send`, `emails.read`, `emails.template.list`,
/// `forms.list`, `forms.read`, `formHandlers.list`,
/// `engagementPrograms.list`, `engagementSteps.list`,
/// `engagementEvents.list`, `campaigns.create`, `campaigns.update`,
/// `campaigns.query`, `users.read`, `users.query`,
/// `visitors.read`, `visitorActivities.query`, `tags.create`,
/// `tags.update`, `lifecycleStages.query`, `customFields.list`,
/// `externalActivities.create`, `oauth.token`.
Future<T> tracedPardot<T>({
  required String operation,
  required Future<PardotCallResult<T>> Function() invoke,
}) async {
  if (pardotInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'pardot',
    'rpc.method': operation,
    'pardot.operation': operation,
  };

  final span = _tracer().startSpan(
    'pardot $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.businessUnitId != null) {
        extras.add(OTel.attributeString(
          'pardot.business_unit.id',
          res.businessUnitId!,
        ));
      }
      if (res.objectKind != null) {
        extras.add(OTel.attributeString(
          'pardot.object.kind',
          res.objectKind!,
        ));
      }
      if (res.objectId != null) {
        extras.add(OTel.attributeString('pardot.object.id', res.objectId!));
      }
      if (res.action != null) {
        extras.add(OTel.attributeString('pardot.action', res.action!));
      }
      if (res.prospectGrade != null) {
        extras.add(OTel.attributeString(
          'pardot.prospect.grade',
          res.prospectGrade!,
        ));
      }
      if (res.prospectScore != null) {
        extras.add(OTel.attributeInt(
          'pardot.prospect.score',
          res.prospectScore!,
        ));
      }
      if (res.listEmailId != null) {
        extras.add(OTel.attributeString(
          'pardot.list_email.id',
          res.listEmailId!,
        ));
      }
      if (res.deliveredCount != null) {
        extras.add(OTel.attributeInt(
          'pardot.email.delivered_count',
          res.deliveredCount!,
        ));
      }
      if (res.openCount != null) {
        extras.add(OTel.attributeInt(
          'pardot.email.open_count',
          res.openCount!,
        ));
      }
      if (res.clickCount != null) {
        extras.add(OTel.attributeInt(
          'pardot.email.click_count',
          res.clickCount!,
        ));
      }
      if (res.bouncedCount != null) {
        extras.add(OTel.attributeInt(
          'pardot.email.bounced_count',
          res.bouncedCount!,
        ));
      }
      if (res.unsubscribedCount != null) {
        extras.add(OTel.attributeInt(
          'pardot.email.unsubscribed_count',
          res.unsubscribedCount!,
        ));
      }
      if (res.formId != null) {
        extras.add(OTel.attributeString('pardot.form.id', res.formId!));
      }
      if (res.formSubmissions != null) {
        extras.add(OTel.attributeInt(
          'pardot.form.submissions',
          res.formSubmissions!,
        ));
      }
      if (res.campaignId != null) {
        extras.add(OTel.attributeString(
          'pardot.campaign.id',
          res.campaignId!,
        ));
      }
      if (res.engagementProgram != null) {
        extras.add(OTel.attributeString(
          'pardot.engagement.program',
          res.engagementProgram!,
        ));
      }
      if (res.engagementStep != null) {
        extras.add(OTel.attributeString(
          'pardot.engagement.step',
          res.engagementStep!,
        ));
      }
      if (res.dailyApiCallsUsed != null) {
        extras.add(OTel.attributeInt(
          'pardot.quota.daily_used',
          res.dailyApiCallsUsed!,
        ));
      }
      if (res.dailyApiCallsLimit != null) {
        extras.add(OTel.attributeInt(
          'pardot.quota.daily_limit',
          res.dailyApiCallsLimit!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'pardot.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Pardot ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'pardot.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'Pardot HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
