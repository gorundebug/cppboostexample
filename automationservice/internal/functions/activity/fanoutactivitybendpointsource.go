package activity

import (
	"context"

	temporalsource "github.com/gorundebug/servicelib/datasource/temporal"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsource.EndpointHandler[FanoutActivityBEndpointSourceHandlerState, string, string, string, error] = (*FanoutActivityBEndpointSource)(nil)

type FanoutActivityBEndpointSourceHandlerState struct{}

// FanoutActivityBEndpointSource handles one value acquired from the Temporal endpoint before it
// enters the ordinary runtime graph.
type FanoutActivityBEndpointSource struct{}

func (ep *FanoutActivityBEndpointSource) BeginRequest(ctx context.Context, _ temporalsource.StreamContext[string, string, error]) (context.Context, FanoutActivityBEndpointSourceHandlerState, error) {
	return ctx, FanoutActivityBEndpointSourceHandlerState{}, nil
}

func (ep *FanoutActivityBEndpointSource) ConsumeMessage(ctx context.Context, sc temporalsource.StreamContext[string, string, error], _ FanoutActivityBEndpointSourceHandlerState, value string) error {
	sc.Collect(ctx, value)
	return nil
}

func (ep *FanoutActivityBEndpointSource) EndRequest(_ context.Context, _ temporalsource.StreamContext[string, string, error], _ error, _ FanoutActivityBEndpointSourceHandlerState) {
}

func MakeFanoutActivityBEndpointSource(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutActivityBEndpointSource, error) {
	return &FanoutActivityBEndpointSource{}, nil
}
