package edu.emory.cloudypipelines.nexusweb.service;

import edu.emory.cloudypipelines.nexusweb.bean.CPJobStatus;
import edu.emory.cloudypipelines.nexusweb.bean.CommonRequest;
import edu.emory.cloudypipelines.nexusweb.bean.ProcessStatus;
import edu.emory.cloudypipelines.nexusweb.bean.RequestJobsResponseMsg;
import edu.emory.cloudypipelines.nexusweb.controller.ControllerUtil;
import edu.emory.cloudypipelines.nexusweb.db.entity.Task;
import edu.emory.cloudypipelines.nexusweb.db.repo.TaskRepo;
import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AsyncService {
    private static final Logger LOGGER = LoggerFactory.getLogger(AsyncService.class);

    public final String submissionRootDir = "/tmp/nexus-web/dc";

    @Autowired
    TaskRepo taskRepo;

    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;

    @Async
    public void submitNextAndUpdate(CommonRequest commonRequest, String wdlFilePath, String inputJsonFilePath, Task nextTask) {
        final String methodName = Thread.currentThread().getName() + ": submitNextAndUpdate():";
        //wait a while to make sure the outputs from previous are ready
        int secondsToSleep = 30;
        try {
            Thread.sleep(secondsToSleep * 1000);
        } catch (InterruptedException ie) {
            LOGGER.error("{} InterruptedException", methodName, ie.getMessage());
        }

        ResponseEntity<RequestJobsResponseMsg> responseEntity = cloudyPipelinesHttpClient.submitByFilePath(commonRequest, wdlFilePath, inputJsonFilePath, null);
        if (!ControllerUtil.isHttpOk(responseEntity.getStatusCodeValue())) {
            LOGGER.error("{} Submission to CloudyPipelines Failed for taskLabel={}", methodName, commonRequest.getLabel());
            nextTask.setCompleted(true);
            nextTask.setProcessStatus(String.valueOf(ProcessStatus.Failed));
            nextTask.setNote("Submission to CloudyPipelines Failed");
            taskRepo.save(nextTask);
            return;
        }
        updateTaskByHttpResponse(nextTask, responseEntity);
        taskRepo.save(nextTask);
    }

    boolean updateTaskByHttpResponse(Task task, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
        RequestJobsResponseMsg requestJobsResponseMsg = responseEntity.getBody();
        if (requestJobsResponseMsg == null) {
            LOGGER.error("updateTask(): CloudyPipelines requestJobsResponseMsg is null, something wrong");
            task.setCompleted(true);
            task.setNote("CloudyPipelines requestJobsResponseMsg is null, something wrong");
            task.setProcessStatus(String.valueOf(ProcessStatus.Failed));
            return false;
        }
        task.setRequestId(requestJobsResponseMsg.getRequestId());
        List<CPJobStatus> cpJobStatuses = requestJobsResponseMsg.getJobStatusList();
        if (cpJobStatuses == null || cpJobStatuses.isEmpty()) {
            LOGGER.error("updateTask(): CloudyPipelines requestJobsResponseMsg job list is null, something wrong");
            task.setCompleted(true);
            task.setNote("CloudyPipelines requestJobsResponseMsg job list is null, something wrong");
            task.setProcessStatus(String.valueOf(ProcessStatus.Failed));
            return false;
        }
        // should be only one
        task.setCromwellId(cpJobStatuses.get(0).getId());
        task.setProcessStatus(String.valueOf(ProcessStatus.Submitted));
        task.setTimeSubmitted(CommonUtil.getUTCNow());
        task.setTimeCompleted(null);
        task.setStartMillis(CommonUtil.getEpochMilli(task.getTimeSubmitted()));
        task.setEndMillis(null);
        return true;
    }

}
