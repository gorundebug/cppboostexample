// Dashboard: IBM Sarama Client
//
// Source: Sarama's documented Config.MetricRegistry. The framework reads the
// registry through observable gauges only when application metrics are
// collected; Kafka's publish and consume paths are unchanged.

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-v11.0.0/main.libsonnet';
local lib = import '_lib.libsonnet';

local jobFilter = 'job=~"$job"';

lib.dashboard(
  title='%s / Kafka Client (IBM Sarama)' % lib.svc,
  uid='%s-kafka-client' % lib.svc,
  tags=['kafka', 'sarama', 'go'],
  variables=[
    lib.dsVar,
    lib.jobVar('sarama_kafka_client_requests_count'),
  ],
  panels=[
    lib.row('Connections and requests'),

    lib.ts(
      title='Broker Metric Sets and In-flight Requests',
      targets=[
        lib.promQ('sarama_kafka_client_broker_metric_sets{%s}' % jobFilter, '{{role}} brokers'),
        lib.promQ('sarama_kafka_client_requests_in_flight{%s}' % jobFilter, '{{role}} in flight'),
      ],
      w=12, h=8,
      unit='short',
    ),

    lib.ts(
      title='Request and Response Rate',
      targets=[
        lib.promQ('sarama_kafka_client_request_rate{%s}' % jobFilter, '{{role}} requests'),
        lib.promQ('sarama_kafka_client_response_rate{%s}' % jobFilter, '{{role}} responses'),
      ],
      w=12, h=8,
      unit='ops',
    ),

    lib.row('Traffic'),

    lib.ts(
      title='Network Throughput',
      targets=[
        lib.promQ('sarama_kafka_client_bytes_sent_rate{%s}' % jobFilter, '{{role}} sent'),
        lib.promQ('sarama_kafka_client_bytes_received_rate{%s}' % jobFilter, '{{role}} received'),
      ],
      w=12, h=8,
      unit='Bps',
    ),

    lib.ts(
      title='Records Sent and Fetch Requests',
      targets=[
        lib.promQ('sarama_kafka_client_record_send_rate{%s,role="producer"}' % jobFilter, 'records sent'),
        lib.promQ('sarama_kafka_client_fetch_rate{%s,role="consumer"}' % jobFilter, 'consumer fetches'),
      ],
      w=12, h=8,
      unit='ops',
    ),

    lib.row('Consumer group'),

    lib.ts(
      title='Join and Sync Attempts',
      targets=[
        lib.promQ('sarama_kafka_client_consumer_group_joins_count{%s,role="consumer"}' % jobFilter, 'joins'),
        lib.promQ('sarama_kafka_client_consumer_group_syncs_count{%s,role="consumer"}' % jobFilter, 'syncs'),
      ],
      w=12, h=8,
      unit='short',
    ),

    lib.ts(
      title='Join and Sync Failures',
      targets=[
        lib.promQ('sarama_kafka_client_consumer_group_join_failures_count{%s,role="consumer"}' % jobFilter, 'join failures'),
        lib.promQ('sarama_kafka_client_consumer_group_sync_failures_count{%s,role="consumer"}' % jobFilter, 'sync failures'),
      ],
      w=12, h=8,
      unit='short',
    ),
  ]
)
