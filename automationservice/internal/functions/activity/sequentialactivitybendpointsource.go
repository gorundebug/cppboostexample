package activity

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[SequentialActivityBEndpointSourceHandlerState, string, string, string, error] = (*SequentialActivityBEndpointSource)(nil)

type SequentialActivityBEndpointSourceHandlerState struct{}

// SequentialActivityBEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type SequentialActivityBEndpointSource struct{}

func (ep *SequentialActivityBEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, SequentialActivityBEndpointSourceHandlerState, error) {
	return ctx, SequentialActivityBEndpointSourceHandlerState{}, nil
}

func (ep *SequentialActivityBEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ SequentialActivityBEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *SequentialActivityBEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ SequentialActivityBEndpointSourceHandlerState) {
}

func MakeSequentialActivityBEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*SequentialActivityBEndpointSource, error) {
	return &SequentialActivityBEndpointSource{}, nil
}
