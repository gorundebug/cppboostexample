package activity

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[ActivityJobEndpointSinkHandlerState, string] = (*ActivityJobEndpointSink)(nil)

type ActivityJobEndpointSinkHandlerState struct{}

// ActivityJobEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type ActivityJobEndpointSink struct{}

func (ep *ActivityJobEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ ActivityJobEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *ActivityJobEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, ActivityJobEndpointSinkHandlerState) {
	return ctx, ActivityJobEndpointSinkHandlerState{}
}

func (ep *ActivityJobEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ ActivityJobEndpointSinkHandlerState) {
}

func MakeActivityJobEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*ActivityJobEndpointSink, error) {
	return &ActivityJobEndpointSink{}, nil
}
