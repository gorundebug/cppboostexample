#include <gtest/gtest.h>

#include <orderservice/internal/functions/order/soft_deadline.hpp>
#include <servicelib/runtime/testlog/testlog.hpp>
#include <servicelib/runtime/testmetrics/testmetrics.hpp>

namespace {

using namespace std::chrono_literals;
namespace cfg = servicelib::config;
using example::order_service::functions::SoftDeadline;

class DeadlineConfig final : public cfg::IConfig {
 public:
  DeadlineConfig() {
    first.id = 1;
    first.name = "first-deadline";
    first.duration = 125;
    second.id = 2;
    second.name = "second-deadline";
    second.duration = 350;
  }

  std::vector<const cfg::ServiceConfig*> GetServices() const override { return {}; }
  std::vector<cfg::StreamConfigRef> GetStreams() const override {
    return {first, second};
  }
  std::vector<cfg::DataConnectorConfigRef> GetDataConnectors() const override {
    return {};
  }
  std::vector<cfg::EndpointConfigRef> GetEndpoints() const override { return {}; }
  std::vector<const cfg::PoolConfig*> GetPools() const override { return {}; }
  std::vector<const cfg::LinkConfig*> GetLinks() const override { return {}; }
  std::vector<const cfg::ModuleConfig*> GetModules() const override { return {}; }
  std::vector<const cfg::TypeConfig*> GetTypes() const override { return {}; }

  cfg::DelayStreamConfig first;
  cfg::DelayStreamConfig second;
};

class DeadlineEnvironment final : public servicelib::IRuntimeEnvironment {
 public:
  DeadlineEnvironment()
      : runtime_(std::make_shared<const cfg::RuntimeConfig>(config_)) {}

  std::shared_ptr<const cfg::RuntimeConfig> getRuntimeConfigSnapshot() const override {
    return runtime_;
  }
  std::shared_ptr<const cfg::ServiceConfig> getServiceConfigSnapshot() const override {
    return {};
  }
  servicelib::pool::ITaskPool* getTaskPool(const std::string&) override {
    return nullptr;
  }
  servicelib::pool::IPriorityTaskPool* getPriorityTaskPool(const std::string&) override {
    return nullptr;
  }
  servicelib::log::Logger& getLogger() override { return logger_; }
  servicelib::metrics::Metrics& getMetrics() override { return metrics_; }
  servicelib::tracing::Tracing* getTracing() override { return nullptr; }

 private:
  DeadlineConfig config_;
  std::shared_ptr<const cfg::RuntimeConfig> runtime_;
  servicelib::testlog::TestLog logger_;
  servicelib::testmetrics::TestMetrics metrics_;
};

class DeadlineStream final : public servicelib::StreamBase {
 public:
  DeadlineStream(servicelib::IRuntimeEnvironment* environment, size_t id) {
    setConfigId(id);
    setEnv(environment);
  }
  ~DeadlineStream() override = default;

 private:
  size_t buildTopology(servicelib::StreamBuilderContext&, size_t id,
                       std::vector<size_t>*, bool) override { return id; }
  void verifyTopology(servicelib::StreamVerifyContext&) const override {}
  void printTopology(servicelib::TopologyPrinter&,
                     std::unordered_set<size_t>&) const override {}
};

TEST(SoftDeadlineConfig, SharedFunctionUsesCallingStreamConfiguration) {
  DeadlineEnvironment environment;
  DeadlineStream first{&environment, 1};
  DeadlineStream second{&environment, 2};
  SoftDeadline function;
  const example::order_service::types::Order order{};

  EXPECT_EQ(function(servicelib::MessageContext{}, first, order), 125ms);
  EXPECT_EQ(function(servicelib::MessageContext{}, second, order), 350ms);
  EXPECT_EQ(function(servicelib::MessageContext{}, first, order), 125ms);
}

TEST(SoftDeadlineConfig, ExplicitMarginOverridesStreamConfiguration) {
  DeadlineEnvironment environment;
  DeadlineStream stream{&environment, 1};
  SoftDeadline function{75ms};
  EXPECT_EQ(function(servicelib::MessageContext{}, stream,
                     example::order_service::types::Order{}), 75ms);
}

TEST(SoftDeadlineConfig, MissingEnvironmentIsNotSilentlyZeroMargin) {
  DeadlineStream stream{nullptr, 1};
  SoftDeadline function;
  EXPECT_THROW(function(servicelib::MessageContext{}, stream,
                        example::order_service::types::Order{}), std::logic_error);
}

TEST(SoftDeadlineConfig, MissingStreamConfigurationIsReported) {
  DeadlineEnvironment environment;
  DeadlineStream stream{&environment, 99};
  SoftDeadline function;
  EXPECT_THROW(function(servicelib::MessageContext{}, stream,
                        example::order_service::types::Order{}), std::logic_error);
}

}  // namespace
