// Dashboard: gRPC Server (ServiceLib endpoint metrics)

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-v11.0.0/main.libsonnet';
local lib = import '_lib.libsonnet';

local jobFilter = 'job=~"$job", protocol="grpc"';
local connFilter = '%s, connector=~"$connector"' % jobFilter;
local epFilter = '%s, endpoint=~"$endpoint"' % connFilter;

lib.dashboard(
  title='%s / gRPC Server' % lib.svc,
  uid='%s-grpc-server' % lib.svc,
  tags=['grpc', 'server'],
  variables=[
    lib.dsVar,
    lib.jobVar('datasource_endpoint_messages_total'),
    lib.labelVar('connector', 'connector', 'datasource_endpoint_messages_total', jobFilter),
    lib.labelVar('endpoint', 'endpoint', 'datasource_endpoint_messages_total', connFilter),
  ],
  panels=[
    lib.row('Traffic'),
    lib.ts('RPC Rate', [lib.rate('datasource_endpoint_messages_total', epFilter, '{{connector}} / {{endpoint}}')], w=12, h=8, unit='ops'),
    lib.ts('Active RPCs', [lib.promQ('datasource_endpoint_active_requests{%s}' % epFilter, '{{connector}} / {{endpoint}}')], w=12, h=8),
    lib.row('Latency'),
    lib.ts('Call Duration p50', [lib.hQuantileBy(0.50, 'datasource_endpoint_request_duration_seconds', 'connector, endpoint', epFilter, 'p50 {{connector}} / {{endpoint}}')], w=8, h=8, unit='s'),
    lib.ts('Call Duration p95', [lib.hQuantileBy(0.95, 'datasource_endpoint_request_duration_seconds', 'connector, endpoint', epFilter, 'p95 {{connector}} / {{endpoint}}')], w=8, h=8, unit='s'),
    lib.ts('Call Duration p99', [lib.hQuantileBy(0.99, 'datasource_endpoint_request_duration_seconds', 'connector, endpoint', epFilter, 'p99 {{connector}} / {{endpoint}}')], w=8, h=8, unit='s'),
    lib.row('Errors'),
    lib.ts('RPC Error Rate', [lib.rate('datasource_endpoint_events_total', '%s, event="request_error"' % epFilter, '{{connector}} / {{endpoint}}')], w=12, h=8, unit='ops'),
    lib.ts('Protocol / Correlation Errors', [
      lib.rate('datasource_endpoint_events_total', '%s, event="begin_request_failed"' % epFilter, 'begin failed {{connector}} / {{endpoint}}'),
      lib.rate('datasource_endpoint_events_total', '%s, event="late_result"' % epFilter, 'late result {{connector}} / {{endpoint}}'),
      lib.rate('datasource_endpoint_events_total', '%s, event="unknown_message_id"' % epFilter, 'unknown message {{connector}} / {{endpoint}}'),
    ], w=12, h=8, unit='ops'),
  ]
)
