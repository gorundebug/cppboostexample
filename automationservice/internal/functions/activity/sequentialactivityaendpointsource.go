package activity

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[SequentialActivityAEndpointSourceHandlerState, string, string, string, error] = (*SequentialActivityAEndpointSource)(nil)

type SequentialActivityAEndpointSourceHandlerState struct{}

// SequentialActivityAEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type SequentialActivityAEndpointSource struct{}

func (ep *SequentialActivityAEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, SequentialActivityAEndpointSourceHandlerState, error) {
	return ctx, SequentialActivityAEndpointSourceHandlerState{}, nil
}

func (ep *SequentialActivityAEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ SequentialActivityAEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *SequentialActivityAEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ SequentialActivityAEndpointSourceHandlerState) {
}

func MakeSequentialActivityAEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*SequentialActivityAEndpointSource, error) {
	return &SequentialActivityAEndpointSource{}, nil
}
