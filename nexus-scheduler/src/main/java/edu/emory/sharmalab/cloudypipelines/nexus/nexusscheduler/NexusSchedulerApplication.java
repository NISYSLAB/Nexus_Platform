package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import javax.annotation.PostConstruct;
import java.util.concurrent.Executor;

// see https://spring.io/guides/gs/async-method/

@SpringBootApplication
@EnableScheduling
@EnableAsync
public class NexusSchedulerApplication {
    private static final Logger LOGGER = LoggerFactory.getLogger(NexusSchedulerApplication.class);

    @Value("${executor_core_pool_size}")
    private Integer executorCorePoolSize;

    @Value("${executor_max_pool_size}")
    private Integer executorMaxPoolSize;

    @Value("${executor_queue_capacity}")
    private Integer executorQueueCapacity;

    // for GRA Pipeline
    @Value("${gra_core_pool_size}")
    private Integer graCorePoolSize;

    @Value("${gra_max_pool_size}")
    private Integer graMaxPoolSize;

    @Value("${gra_queue_capacity}")
    private Integer graQueueCapacity;

    public static void main(String[] args) {
        SpringApplication.run(NexusSchedulerApplication.class, args);
        // close the application context to shut down the custom ExecutorService
        //SpringApplication.run(NexusSchedulerApplication.class, args).close();
    }

    @PostConstruct
    void init() {
        final String methodName = "init():";
        LOGGER.info("{} executorCorePoolSize={}", methodName, executorCorePoolSize);
        LOGGER.info("{} executorMaxPoolSize={}", methodName, executorMaxPoolSize);
        LOGGER.info("{} executorQueueCapacity={}", methodName, executorQueueCapacity);
        LOGGER.info("{} graCorePoolSize={}", methodName, graCorePoolSize);
        LOGGER.info("{} graMaxPoolSize={}", methodName, graMaxPoolSize);
        LOGGER.info("{} graQueueCapacity={}", methodName, graQueueCapacity);
    }

    @Bean(name = "nexusSchedulerExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(executorCorePoolSize);
        executor.setMaxPoolSize(executorMaxPoolSize);
        executor.setQueueCapacity(executorQueueCapacity);
        executor.setThreadNamePrefix("nexusScheduler-");
        executor.initialize();
        return executor;
    }

    @Bean(name = "graPipelineExecutor")
    public Executor graExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(graCorePoolSize);
        executor.setMaxPoolSize(graMaxPoolSize);
        executor.setQueueCapacity(graQueueCapacity);
        executor.setThreadNamePrefix("graScheduler-");
        executor.initialize();
        return executor;
    }

    // Implementation, use @Async at method level to make the method Asynchronous.
    // Methods need to be public to use @Async.
    // Also, @Async annotated method calling @Async method will not work.

}
