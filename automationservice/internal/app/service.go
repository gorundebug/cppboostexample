package app

import (
	"context"
	"net/http"
	"os"
	"reflect"
	"strings"

	"github.com/gorundebug/servicelib/api"
	"github.com/gorundebug/servicelib/runtime"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/runtime/environment/log"
	"github.com/gorundebug/servicelib/runtime/environment/metrics"
	"github.com/gorundebug/servicelib/runtime/environment/tracing"
	"github.com/gorundebug/servicelib/runtime/logging"
	"github.com/gorundebug/servicelib/runtime/serde"
	"github.com/gorundebug/servicelib/runtime/telemetry"
)

// serviceDependencies provides the service-level dependency overrides.
type serviceDependencies struct {
}

func environmentFlagEnabled(name string) bool {
	switch strings.ToLower(strings.TrimSpace(os.Getenv(name))) {
	case "1", "true", "yes", "on":
		return true
	default:
		return false
	}
}

// MetricsEngine creates the metrics engine used by the service.
// local/debug: Prometheus (pull-based, exposes /metrics endpoint).
// staging/production: OTLP metrics (push-based, no /metrics endpoint required).
func (d *serviceDependencies) MetricsEngine(ctx context.Context, env environment.ServiceEnvironment) (metrics.MetricsEngine, error) {
	if environmentFlagEnabled("SERVICELIB_NOOP_METRICS") {
		return metrics.NewNoopMetricsEngine(), nil
	}
	switch env.ServiceConfig().Environment {
	case api.EnvironmentStaging, api.EnvironmentProduction:
		return telemetry.CreateOTLPMetricsEngine(ctx, env)
	default: // local, debug, or unset
		return telemetry.CreatePrometheusMetricsEngine(env)
	}
}

// LogsEngine creates the logging engine used by the service.
// local/debug: human-readable Logrus output.
// staging/production: structured logs exported via OTLP.
func (d *serviceDependencies) LogsEngine(ctx context.Context, env environment.ServiceEnvironment) (log.LogsEngine, error) {
	switch env.ServiceConfig().Environment {
	case api.EnvironmentStaging, api.EnvironmentProduction:
		return telemetry.CreateOTLPLogsEngine(ctx, env)
	default: // local, debug, or unset
		return logging.CreateLogsEngine(logging.Logrus, env)
	}
}

// DelayPool returns a custom delay pool implementation, or nil to use the default
// time.AfterFunc-based pool (sync.Once guarantees fn is called exactly once on either timer or ctx cancel).
func (d *serviceDependencies) DelayPool(_ context.Context, _ environment.ServiceEnvironment) (environment.DelayPool, error) {
	return nil, nil
}

// TracingEngine creates the distributed tracing engine used by the service.
// local/debug: pretty human-readable output with per-request opt-in via context.
// staging/production: traces exported via OTLP.
func (d *serviceDependencies) TracingEngine(ctx context.Context, env environment.ServiceEnvironment) (tracing.TracingEngine, error) {
	if environmentFlagEnabled("SERVICELIB_NOOP_TRACING") {
		return tracing.NewNoopTracingEngine(), nil
	}
	switch env.ServiceConfig().Environment {
	case api.EnvironmentStaging, api.EnvironmentProduction:
		return telemetry.CreateOTLPTracingEngine(ctx, env)
	default: // local, debug, or unset
		return telemetry.CreatePrettyTracingEngine(env, telemetry.WithContextSampler())
	}
}

// getCustomSerde returns a custom serializer for the given type, or nil to fall
// back to the default serde. Implement this to override serialization for
// specific types used in your pipeline.
func (s *Service) getCustomSerde(valueType reflect.Type) (serde.Serializer, error) {
	return nil, nil
}

// start is called after the pipeline is built and before the service begins
// accepting requests. HTTP datasource endpoint handlers are registered
// automatically by the generated code in buildRuntime. Add any additional
// custom startup logic here.
func (s *Service) start(ctx context.Context) error {
	return nil
}

// stop is called during graceful shutdown before the service exits.
// Release any resources acquired in start (e.g. close connections, flush buffers).
func (s *Service) stop(ctx context.Context) {
}

// httpServerMakers sets the makers for the HTTP mux and server.
// By default both return nil — the library's built-in HTTP server is used
// (created from HttpHost/HttpPort in the service config).
//
// Override these makers when you need full control over the HTTP server:
//   - httpMuxMaker: create and configure your own ServeMux.
//   - httpServerMaker: create the http.Server using the mux produced above.
//     The server address is taken from the service config (HttpHost/HttpPort).
//     Wrap the mux with MetricsEngine.HTTPServerHandler to get per-route metrics.
//
// When non-nil values are returned, the library's built-in server is NOT created
// and the generated code manages the full lifecycle (Listen/Serve/Shutdown).
func (s *Service) httpServerMakers(ctx context.Context) error {
	s.httpServerMaker = func(_ context.Context, env runtime.RuntimeEnvironment) (*http.Server, error) {
		// svcCfg := s.ServiceConfig()
		// return &http.Server{
		//    Addr: fmt.Sprintf("%s:%d", svcCfg.HttpHost, svcCfg.HttpPort),
		//    Handler: env.MetricsEngine().HTTPServerHandler(s.httpMux, runtime.ToSnakeCase(svcCfg.Name)),
		// }, nil
		return nil, nil
	}
	return nil
}

// customMakersInit is called during pipeline construction before any stream or
// endpoint makers run. Use it to override default makers: gRPC server/client,
// HTTP server/mux, serializers, etc. httpServerMakers is always called here to
// ensure the HTTP makers are set before the pipeline is built.
func (s *Service) customMakersInit(ctx context.Context) error {
	if err := s.httpServerMakers(ctx); err != nil {
		return err
	}
	return nil
}

// customFunctionsInit is called after all stream and endpoint functions have
// been initialised. Use it to perform any cross-cutting setup that depends on
// the fully wired pipeline (e.g. inject shared state into handlers).
func (s *Service) customFunctionsInit(ctx context.Context) error {
	return nil
}

// httpHandlerMiddleware wraps every HTTP handler registered via RegisterHTTPHandler.
// Override it to add cross-cutting concerns such as authentication, tracing,
// request logging, or rate limiting for all routes uniformly.
func (s *Service) httpHandlerMiddleware(path string, handler http.Handler) http.Handler {
	return handler
}
