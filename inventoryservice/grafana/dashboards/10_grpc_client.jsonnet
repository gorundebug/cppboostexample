// Dashboard: gRPC Client (ServiceLib endpoint metrics)

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-v11.0.0/main.libsonnet';
local lib = import '_lib.libsonnet';

local jobFilter = 'job=~"$job", protocol="grpc"';
local connFilter = '%s, connector=~"$connector"' % jobFilter;
local epFilter = '%s, endpoint=~"$endpoint"' % connFilter;

lib.dashboard(
  title='%s / gRPC Client' % lib.svc,
  uid='%s-grpc-client' % lib.svc,
  tags=['grpc', 'client'],
  variables=[
    lib.dsVar,
    lib.jobVar('datasink_endpoint_messages_total'),
    lib.labelVar('connector', 'connector', 'datasink_endpoint_messages_total', jobFilter),
    lib.labelVar('endpoint', 'endpoint', 'datasink_endpoint_messages_total', connFilter),
  ],
  panels=[
    lib.row('Traffic'),
    lib.ts('RPC Rate', [lib.rate('datasink_endpoint_messages_total', epFilter, '{{connector}} / {{endpoint}}')], w=12, h=8, unit='ops'),
    lib.ts('Active RPCs', [lib.promQ('datasink_endpoint_active_requests{%s}' % epFilter, '{{connector}} / {{endpoint}}')], w=12, h=8),
    lib.row('Latency'),
    lib.ts('Call Duration p50', [lib.hQuantileBy(0.50, 'datasink_endpoint_request_duration_seconds', 'connector, endpoint', epFilter, 'p50 {{connector}} / {{endpoint}}')], w=8, h=8, unit='s'),
    lib.ts('Call Duration p95', [lib.hQuantileBy(0.95, 'datasink_endpoint_request_duration_seconds', 'connector, endpoint', epFilter, 'p95 {{connector}} / {{endpoint}}')], w=8, h=8, unit='s'),
    lib.ts('Call Duration p99', [lib.hQuantileBy(0.99, 'datasink_endpoint_request_duration_seconds', 'connector, endpoint', epFilter, 'p99 {{connector}} / {{endpoint}}')], w=8, h=8, unit='s'),
    lib.row('Errors'),
    lib.ts('RPC Error Rate', [lib.rate('datasink_endpoint_events_total', '%s, event="request_error"' % epFilter, '{{connector}} / {{endpoint}}')], w=12, h=8, unit='ops'),
    lib.ts('Lifecycle Error Rate', [
      lib.rate('datasink_endpoint_events_total', '%s, event="begin_request_failed"' % epFilter, 'begin failed {{connector}} / {{endpoint}}'),
      lib.rate('datasink_endpoint_events_total', '%s, event="late_result"' % epFilter, 'late result {{connector}} / {{endpoint}}'),
    ], w=12, h=8, unit='ops'),
  ]
)
