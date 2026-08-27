package activity

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[FanoutActivityAEndpointSourceHandlerState, string, string, string, error] = (*FanoutActivityAEndpointSource)(nil)

type FanoutActivityAEndpointSourceHandlerState struct{}

// FanoutActivityAEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type FanoutActivityAEndpointSource struct{}

func (ep *FanoutActivityAEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, FanoutActivityAEndpointSourceHandlerState, error) {
	return ctx, FanoutActivityAEndpointSourceHandlerState{}, nil
}

func (ep *FanoutActivityAEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ FanoutActivityAEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *FanoutActivityAEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ FanoutActivityAEndpointSourceHandlerState) {
}

func MakeFanoutActivityAEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutActivityAEndpointSource, error) {
	return &FanoutActivityAEndpointSource{}, nil
}
