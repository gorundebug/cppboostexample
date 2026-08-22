// Dashboard: librdkafka Client
//
// Source: librdkafka's documented statistics.interval.ms and stats_cb API.
// Values are emitted once per second only while application metrics are
// enabled.

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-v11.0.0/main.libsonnet';
local lib = import '_lib.libsonnet';

local jobFilter = 'job=~"$job"';

lib.dashboard(
  title='%s / Kafka Client (librdkafka)' % lib.svc,
  uid='%s-kafka-client' % lib.svc,
  tags=['kafka', 'librdkafka', 'cppboost'],
  variables=[lib.dsVar, lib.jobVar('kafka_client_brokers')],
  panels=[
    lib.row('Connections'),
    lib.ts(
      title='Known and Connected Brokers',
      targets=[
        lib.promQ('kafka_client_brokers{%s}' % jobFilter, '{{role}} known'),
        lib.promQ('kafka_client_brokers_up{%s}' % jobFilter, '{{role}} connected'),
      ],
      w=12, h=8, unit='short',
    ),
    lib.ts(
      title='Consumer Lag',
      targets=[lib.promQ('kafka_client_consumer_lag{%s,role="consumer"}' % jobFilter, '{{job}}')],
      w=12, h=8, unit='short',
    ),
    lib.row('Queues'),
    lib.ts(
      title='Queued Messages and Replies',
      targets=[
        lib.promQ('kafka_client_messages_queued{%s}' % jobFilter, '{{role}} messages'),
        lib.promQ('kafka_client_reply_queue_messages{%s}' % jobFilter, '{{role}} replies'),
      ],
      w=12, h=8, unit='short',
    ),
    lib.ts(
      title='Queued Message Bytes',
      targets=[lib.promQ('kafka_client_message_bytes_queued{%s}' % jobFilter, '{{role}}')],
      w=12, h=8, unit='bytes',
    ),
    lib.row('Traffic'),
    lib.ts(
      title='Network Throughput',
      targets=[
        lib.rate('kafka_client_bytes_sent', jobFilter, '{{role}} sent'),
        lib.rate('kafka_client_bytes_received', jobFilter, '{{role}} received'),
      ],
      w=12, h=8, unit='Bps',
    ),
    lib.ts(
      title='Kafka Requests and Responses',
      targets=[
        lib.rate('kafka_client_requests_sent', jobFilter, '{{role}} requests'),
        lib.rate('kafka_client_responses_received', jobFilter, '{{role}} responses'),
      ],
      w=12, h=8, unit='ops',
    ),
    lib.ts(
      title='Messages Sent and Received',
      targets=[
        lib.rate('kafka_client_messages_sent', jobFilter, '{{role}} sent'),
        lib.rate('kafka_client_messages_received', jobFilter, '{{role}} received'),
      ],
      w=24, h=8, unit='ops',
    ),
  ]
)
