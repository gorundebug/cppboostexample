package activity

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[SequentialActivityAEndpointSinkHandlerState, string] = (*SequentialActivityAEndpointSink)(nil)

type SequentialActivityAEndpointSinkHandlerState struct{}

// SequentialActivityAEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type SequentialActivityAEndpointSink struct{}

func (ep *SequentialActivityAEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ SequentialActivityAEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *SequentialActivityAEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, SequentialActivityAEndpointSinkHandlerState) {
	return ctx, SequentialActivityAEndpointSinkHandlerState{}
}

func (ep *SequentialActivityAEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ SequentialActivityAEndpointSinkHandlerState) {
}

func MakeSequentialActivityAEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*SequentialActivityAEndpointSink, error) {
	return &SequentialActivityAEndpointSink{}, nil
}
