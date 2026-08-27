package workflow

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[FanoutWorkflowJobEndpointSourceHandlerState, string, string, string, error] = (*FanoutWorkflowJobEndpointSource)(nil)

type FanoutWorkflowJobEndpointSourceHandlerState struct{}

// FanoutWorkflowJobEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type FanoutWorkflowJobEndpointSource struct{}

func (ep *FanoutWorkflowJobEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, FanoutWorkflowJobEndpointSourceHandlerState, error) {
	return ctx, FanoutWorkflowJobEndpointSourceHandlerState{}, nil
}

func (ep *FanoutWorkflowJobEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ FanoutWorkflowJobEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *FanoutWorkflowJobEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ FanoutWorkflowJobEndpointSourceHandlerState) {
}

func MakeFanoutWorkflowJobEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutWorkflowJobEndpointSource, error) {
	return &FanoutWorkflowJobEndpointSource{}, nil
}
