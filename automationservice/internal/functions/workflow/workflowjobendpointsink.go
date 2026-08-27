package workflow

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[WorkflowJobEndpointSinkHandlerState, string] = (*WorkflowJobEndpointSink)(nil)

type WorkflowJobEndpointSinkHandlerState struct{}

// WorkflowJobEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type WorkflowJobEndpointSink struct{}

func (ep *WorkflowJobEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ WorkflowJobEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *WorkflowJobEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, WorkflowJobEndpointSinkHandlerState) {
	return ctx, WorkflowJobEndpointSinkHandlerState{}
}

func (ep *WorkflowJobEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ WorkflowJobEndpointSinkHandlerState) {
}

func MakeWorkflowJobEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*WorkflowJobEndpointSink, error) {
	return &WorkflowJobEndpointSink{}, nil
}
