package activity

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[SequentialActivityBEndpointSinkHandlerState, string] = (*SequentialActivityBEndpointSink)(nil)

type SequentialActivityBEndpointSinkHandlerState struct{}

// SequentialActivityBEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type SequentialActivityBEndpointSink struct{}

func (ep *SequentialActivityBEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ SequentialActivityBEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *SequentialActivityBEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, SequentialActivityBEndpointSinkHandlerState) {
	return ctx, SequentialActivityBEndpointSinkHandlerState{}
}

func (ep *SequentialActivityBEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ SequentialActivityBEndpointSinkHandlerState) {
}

func MakeSequentialActivityBEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*SequentialActivityBEndpointSink, error) {
	return &SequentialActivityBEndpointSink{}, nil
}
