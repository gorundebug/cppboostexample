package activity

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[ActivityJobEndpointSourceHandlerState, string, string, string, error] = (*ActivityJobEndpointSource)(nil)

type ActivityJobEndpointSourceHandlerState struct{}

// ActivityJobEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type ActivityJobEndpointSource struct{}

func (ep *ActivityJobEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, ActivityJobEndpointSourceHandlerState, error) {
	return ctx, ActivityJobEndpointSourceHandlerState{}, nil
}

func (ep *ActivityJobEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ ActivityJobEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *ActivityJobEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ ActivityJobEndpointSourceHandlerState) {
}

func MakeActivityJobEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*ActivityJobEndpointSource, error) {
	return &ActivityJobEndpointSource{}, nil
}
