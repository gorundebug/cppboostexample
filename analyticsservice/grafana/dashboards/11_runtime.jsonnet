// Dashboard: Boost.Asio Runtime
//
// Source: cppboostservicelib runtime diagnostics sampled from the shared Asio
// worker executor. No Go, GC or allocator series are fabricated for C++.

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-v11.0.0/main.libsonnet';
local lib = import '_lib.libsonnet';

local jobFilter = 'job=~"$job"';

lib.dashboard(
  title='%s / Boost.Asio Runtime' % lib.svc,
  uid='%s-runtime' % lib.svc,
  tags=['runtime', 'cpp', 'boost', 'asio'],
  variables=[
    lib.dsVar,
    lib.jobVar('runtime_worker_utilization'),
  ],
  panels=[
    lib.row('Worker Executor'),
    lib.ts(
      title='Worker Utilization',
      targets=[lib.promQ('runtime_worker_utilization{%s}' % jobFilter, '{{job}}')],
      w=12, h=8,
      unit='percentunit',
    ),
    lib.ts(
      title='Active Work',
      targets=[lib.promQ('runtime_active_work{%s}' % jobFilter, '{{job}}')],
      w=12, h=8,
      unit='short',
    ),
    lib.row('Event Loop'),
    lib.ts(
      title='Event Loop Lag',
      targets=[lib.promQ('runtime_event_loop_lag_seconds{%s}' % jobFilter, '{{job}}')],
      w=24, h=8,
      unit='s',
    ),
  ]
)
