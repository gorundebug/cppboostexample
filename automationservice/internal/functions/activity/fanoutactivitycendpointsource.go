package activity

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[FanoutActivityCEndpointSourceHandlerState, string, string, string, error] = (*FanoutActivityCEndpointSource)(nil)

type FanoutActivityCEndpointSourceHandlerState struct{}

// FanoutActivityCEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type FanoutActivityCEndpointSource struct{}

func (ep *FanoutActivityCEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, FanoutActivityCEndpointSourceHandlerState, error) {
	return ctx, FanoutActivityCEndpointSourceHandlerState{}, nil
}

func (ep *FanoutActivityCEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ FanoutActivityCEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *FanoutActivityCEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ FanoutActivityCEndpointSourceHandlerState) {
}

func MakeFanoutActivityCEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutActivityCEndpointSource, error) {
	return &FanoutActivityCEndpointSource{}, nil
}
