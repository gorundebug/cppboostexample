package workflow

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[WorkflowJobEndpointSourceHandlerState, string, string, string, error] = (*WorkflowJobEndpointSource)(nil)

type WorkflowJobEndpointSourceHandlerState struct{}

// WorkflowJobEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type WorkflowJobEndpointSource struct{}

func (ep *WorkflowJobEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, WorkflowJobEndpointSourceHandlerState, error) {
	return ctx, WorkflowJobEndpointSourceHandlerState{}, nil
}

func (ep *WorkflowJobEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ WorkflowJobEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *WorkflowJobEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ WorkflowJobEndpointSourceHandlerState) {
}

func MakeWorkflowJobEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*WorkflowJobEndpointSource, error) {
	return &WorkflowJobEndpointSource{}, nil
}
