package workflow

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[FanoutWorkflowJobEndpointSinkHandlerState, string] = (*FanoutWorkflowJobEndpointSink)(nil)

type FanoutWorkflowJobEndpointSinkHandlerState struct{}

// FanoutWorkflowJobEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type FanoutWorkflowJobEndpointSink struct{}

func (ep *FanoutWorkflowJobEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ FanoutWorkflowJobEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *FanoutWorkflowJobEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, FanoutWorkflowJobEndpointSinkHandlerState) {
	return ctx, FanoutWorkflowJobEndpointSinkHandlerState{}
}

func (ep *FanoutWorkflowJobEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ FanoutWorkflowJobEndpointSinkHandlerState) {
}

func MakeFanoutWorkflowJobEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutWorkflowJobEndpointSink, error) {
	return &FanoutWorkflowJobEndpointSink{}, nil
}
