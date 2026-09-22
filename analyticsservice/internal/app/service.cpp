#include "analyticsservice/internal/app/service.hpp"

namespace example::analytics_service::app {

void Service::customMakersInit(servicelib::Context context) {
  (void)context;
  makers_.invoke_analytics_substream = [substream =
      getAnalyzeAnalyticsSubstreamSubStream()](
      servicelib::Context, servicelib::IServiceEnvironment&)
      -> boost::asio::awaitable<
          std::unique_ptr<functions::InvokeAnalyticsSubstream>> {
    co_return std::make_unique<functions::InvokeAnalyticsSubstream>(substream);
  };
}

void Service::customFunctionsInit(servicelib::Context context) {
  (void)context;
  // Add only explicit post-construction customization here.
}
void Service::serviceInit() {}
void Service::serviceStarted() {}
void Service::serviceStopping() noexcept {}

}  // namespace example::analytics_service::app
