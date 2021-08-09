package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

@Getter
@Setter
@NoArgsConstructor
@ToString
@Service
public class RuntimeExecutionService {
    private static final Logger LOGGER = LoggerFactory.getLogger(RuntimeExecutionService.class);
    String[] commands;
    private Runtime runtime = Runtime.getRuntime();

    public void systemUsage() {
        LOGGER.info("systemUsage(): availableProcessors={}, totalMemory={}, freeMemory={}, maxMemory={}",
                getRuntime().availableProcessors(),
                getRuntime().totalMemory(),
                getRuntime().freeMemory(),
                getRuntime().maxMemory()
        );
    }

    public SystemCommandOutput execSystemCommand(String[] cmdarray) {
        final String methodName = "[" + Thread.currentThread().getName() + "] execSystemCommand():";
        LOGGER.info("{} cmdarray={}", methodName, cmdarray);

        try {
            return getOutputs(getRuntime().exec(cmdarray));
        } catch (IOException e) {
            SystemCommandOutput systemCommandOutput = new SystemCommandOutput();
            systemCommandOutput.setErrorOutput(e.getMessage());
            LOGGER.error("{} Exception: ", methodName, e);
            return systemCommandOutput;
        }
    }

    public SystemCommandOutput execSystemCommand(String[] cmdarray, String[] envp) {
        final String methodName = "[" + Thread.currentThread().getName() + "] execSystemCommand():";
        LOGGER.info("{} cmdarray={}, envp={}", methodName, cmdarray, envp);

        try {
            return getOutputs(getRuntime().exec(cmdarray, envp));
        } catch (IOException e) {
            SystemCommandOutput systemCommandOutput = new SystemCommandOutput();
            systemCommandOutput.setErrorOutput(e.getMessage());
            LOGGER.error("{} Exception: ", methodName, e);
            return systemCommandOutput;
        }
    }

    public SystemCommandOutput execSystemCommand(String[] cmdarray, String[] envp, File dir) {
        final String methodName = "[" + Thread.currentThread().getName() + "] execSystemCommand():";
        LOGGER.info("{} cmdarray={}, envp={}, dir={}", methodName, cmdarray, envp, dir);

        try {
            return getOutputs(getRuntime().exec(cmdarray, envp, dir));
        } catch (IOException e) {
            SystemCommandOutput systemCommandOutput = new SystemCommandOutput();
            systemCommandOutput.setErrorOutput(e.getMessage());
            LOGGER.error("{} Exception: ", methodName, e);
            return systemCommandOutput;
        }
    }

    public SystemCommandOutput getOutputs(Process process) {
        final String methodName = "getOutputs():";
        SystemCommandOutput systemCommandOutput = new SystemCommandOutput();
        StringBuffer normalBuffer = new StringBuffer();
        StringBuffer errorBuffer = new StringBuffer();
        try {

            BufferedReader stdOutput = new BufferedReader(new
                    InputStreamReader(process.getInputStream()));
            BufferedReader stdError = new BufferedReader(new
                    InputStreamReader(process.getErrorStream()));

            String s = null;
            while ((s = stdOutput.readLine()) != null) {
                normalBuffer.append(s + System.getProperty("line.separator"));
            }
            systemCommandOutput.setNormalOutput(normalBuffer.toString());

            while ((s = stdError.readLine()) != null) {
                errorBuffer.append(s + System.getProperty("line.separator"));
            }
            systemCommandOutput.setErrorOutput(errorBuffer.toString());

        } catch (IOException e) {
            systemCommandOutput.setErrorOutput(e.getMessage());
            LOGGER.error("{} Exception: ", methodName, e);
        }
        return systemCommandOutput;
    }

}
