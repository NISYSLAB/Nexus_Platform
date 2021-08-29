package edu.emory.cloudypipelines.nexusweb.controller.pipeline;

import edu.emory.cloudypipelines.nexusweb.bean.*;
import edu.emory.cloudypipelines.nexusweb.bean.generated.TaskAInputDTO;
import edu.emory.cloudypipelines.nexusweb.controller.ControllerUtil;
import edu.emory.cloudypipelines.nexusweb.db.entity.Task;
import edu.emory.cloudypipelines.nexusweb.db.entity.TaskHeader;
import edu.emory.cloudypipelines.nexusweb.db.repo.TaskHeaderRepo;
import edu.emory.cloudypipelines.nexusweb.db.repo.TaskRepo;
import edu.emory.cloudypipelines.nexusweb.service.CloudyPipelinesHttpClient;
import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import io.swagger.annotations.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/registered/DistributedComputing")
@Api(tags = "API > DistributedComputingPOC")
public class DistributedComputing {

    public static final String CONTAINER_A_WDL_PATH = "/Users/anniegu/workspace/Nexus_Platform/nexus-web/poc_workflow/containerA.wdl";
    public static final String CONTAINER_B_WDL_PATH = "/Users/anniegu/workspace/Nexus_Platform/nexus-web/poc_workflow/containerB.wdl";
    public static final String CONTAINER_C_WDL_PATH = "/Users/anniegu/workspace/Nexus_Platform/nexus-web/poc_workflow/containerC.wdl";
    private static final Logger LOGGER = LoggerFactory.getLogger(Dicom2nifti.class);
    private static final String WF_NAME = "DistributedComputingPOC";
    private static final String WF_VERSION_1 = "v1";
    private final String submissionRootDir = "/tmp/nexusweb/dc";
    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;
    @Autowired
    TaskHeaderRepo taskHeaderRepo;
    @Autowired
    TaskRepo taskRepo;
    private boolean debug_monitoring = true;

    @RequestMapping(value = "/" + WF_VERSION_1, method = RequestMethod.POST)
    @ApiOperation(value = "Run DistributedComputingPOC: " + WF_NAME + "/" + WF_VERSION_1)
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 404, message = "Not found", response = String.class)})
    public ResponseEntity<?> submitAndRun(
            @ModelAttribute("commonRequest") CommonRequest commonRequest,
            @ApiParam(name = "inputPath", value = "full path of image(s)") @RequestParam(value = "inputPath") String inputPath) {

        LOGGER.info("submitAndRun(): received workflowRunRequest={}, inputPath={}", commonRequest, inputPath);
        return submitMultiEnv(commonRequest, inputPath);
    }

    private ResponseEntity<?> submitMultiEnv(CommonRequest commonRequest, String inputPath) {
        final String methodName = "submitMultiEnv();";
        //stepA: run containerA in bmicluster
        String submissionDir = CommonUtil.makeDestDirWithTimestamp(submissionRootDir);
        String wdlFilePath = CommonUtil.copyFileToDirectory(CONTAINER_A_WDL_PATH, submissionDir);
        String inputJsonFilePath = getTaskAJsonInputFilePath(inputPath, submissionDir);

        ResponseEntity<RequestJobsResponseMsg> responseEntity = cloudyPipelinesHttpClient.submitByFilePath(commonRequest, wdlFilePath, inputJsonFilePath, null);
        if (!ControllerUtil.isHttpOk(responseEntity.getStatusCodeValue())) {
            return ControllerUtil.badRequest("Submission to CloudyPipelines Failed!");
        }
        TaskSubmissionResponse taskSubmissionResponse = postProcessMultiEnv(commonRequest, inputPath, responseEntity);
        if (taskSubmissionResponse.getTaskHeaderId() == null) {
            return ControllerUtil.badRequest("No header created, submission Failed");
        }
        if (taskSubmissionResponse.getTaskMetadataList().isEmpty()) {
            return ControllerUtil.badRequest("No tasks created, submission Failed!");
        }
        return ControllerUtil.OK(taskSubmissionResponse);
        //stepB: run containerB in CloudyPipelines
        //stepC: run containerC in bmicluster
    }

    private TaskSubmissionResponse postProcessMultiEnv(CommonRequest commonRequest, String inputPath, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
        TaskHeader taskHeader = saveNewTaskHeader(inputPath);
        UUID taskHeaderId = taskHeader.getTaskHeaderId();
        //details
        TaskSubmissionResponse taskSubmissionResponse = new TaskSubmissionResponse();
        taskSubmissionResponse.setTaskHeaderId(taskHeaderId);
        taskSubmissionResponse.setInputPath(inputPath);
        List<Task> tasks = saveNewTasks(taskHeaderId, commonRequest, inputPath, responseEntity);
        taskSubmissionResponse.setTaskMetadataList(buildTaskMetadataList(tasks));
        return taskSubmissionResponse;
    }

    private List<TaskMetadata> buildTaskMetadataList(List<Task> tasks) {
        List<TaskMetadata> taskMetadataList = new ArrayList<>();
        if (tasks == null || tasks.isEmpty()) {
            LOGGER.error("buildTaskMetadataList(): task list is null/empty, something wrong");
            return taskMetadataList;
        }
        for (Task task : tasks) {
            taskMetadataList.add(convert(task));
        }
        return taskMetadataList;
    }

    private TaskMetadata convert(Task task) {
        TaskMetadata taskMetadata = new TaskMetadata();
        taskMetadata.setCromwellId(task.getCromwellId());
        taskMetadata.setTaskIndex(task.getTaskIndex());
        taskMetadata.setTaskName(task.getTaskName());
        taskMetadata.setTaskId(task.getTaskId());
        taskMetadata.setProject(task.getProject());
        taskMetadata.setProcessStatus(task.getProcessStatus());
        taskMetadata.setRequestId(task.getRequestId());
        taskMetadata.setTimeSubmitted(task.getTimeSubmitted());
        taskMetadata.setProcessStatus(task.getProcessStatus());
        return taskMetadata;
    }

    private List<Task> saveNewTasks(UUID taskHeaderId, CommonRequest commonRequest, String inputPath, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
        List<Task> tasks = new ArrayList<>();
        //TODO will parse from the configuration file from user provides
        // for POC only
        Task task1 = buildTask1(taskHeaderId, responseEntity);
        if (CommonUtil.isNullOrEmpty(task1.getCromwellId())) {
            return tasks;
        }
        Task task2 = buildTask2(taskHeaderId);
        Task task3 = buildTask3(taskHeaderId);
        tasks.add(taskRepo.save(task1));
        tasks.add(taskRepo.save(task2));
        tasks.add(taskRepo.save(task3));
        return tasks;

    }

    private Task buildTask3(UUID taskHeaderId) {
        Task task = buildTask2(taskHeaderId);
        task.setTaskIndex(2);
        task.setTaskName("stepC");
        task.setLabel("stepC");
        task.setProject("nexus-bmi");
        return task;
    }

    private Task buildTask2(UUID taskHeaderId) {
        Task task = new Task();
        task.setTaskHeaderId(taskHeaderId);

        task.setRequestId("");
        task.setCromwellId("");
        task.setTaskIndex(1);
        task.setTaskName("stepB");
        task.setWfType(String.valueOf(WfType.WDL));
        task.setProcessStatus(String.valueOf(ProcessStatus.Waiting));
        task.setProject("cloudypipelines");
        task.setEmail("ping.gu@dbmi.emory.edu");
        task.setLabel("stepB");
        task.setRunningHoursAllowed(24);
        task.setPreemptibleOption(String.valueOf(PreemptibleOption.PREEMPTIBLE_STANDARD_ATTEMPT_BOTH));
        task.setTimeSubmitted(null);
        task.setTimeCompleted(null);
        task.setStartMillis(null);
        task.setEndMillis(null);
        return task;
    }

    //
    private Task buildTask1(UUID taskHeaderId, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
        Task task = new Task();
        task.setTaskHeaderId(taskHeaderId);
        RequestJobsResponseMsg requestJobsResponseMsg = responseEntity.getBody();
        if (requestJobsResponseMsg == null) {
            LOGGER.error("buildTask1(): CloudyPipelines requestJobsResponseMsg is null, something wrong");
            return task;
        }
        task.setRequestId(requestJobsResponseMsg.getRequestId());
        List<CPJob> cpJobs = requestJobsResponseMsg.getJobs();
        if (cpJobs == null || cpJobs.isEmpty()) {
            LOGGER.error("buildTask1(): CloudyPipelines requestJobsResponseMsg job list is null, something wrong");
            return task;
        }
        // should be only one
        task.setCromwellId(cpJobs.get(0).getId());
        task.setTaskIndex(0);
        task.setTaskName("stepA");
        task.setWfType(String.valueOf(WfType.WDL));
        task.setProcessStatus(cpJobs.get(0).getStatus());
        task.setProject("nexus-bmi");
        task.setEmail("ping.gu@dbmi.emory.edu");
        task.setLabel(task.getRequestId().substring(0, 8) + "stepA");
        task.setRunningHoursAllowed(24);
        task.setPreemptibleOption(String.valueOf(PreemptibleOption.PREEMPTIBLE_STANDARD_ATTEMPT_BOTH));
        task.setTimeSubmitted(CommonUtil.getUTCNow());
        task.setTimeCompleted(null);
        task.setStartMillis(CommonUtil.getEpochMilli(task.getTimeSubmitted()));
        task.setEndMillis(null);
        return task;
    }

    private TaskHeader saveNewTaskHeader(String inputPath) {
        TaskHeader taskHeader = new TaskHeader();
        taskHeader.setCompleted(false);
        taskHeader.setInputPath(inputPath);
        taskHeader.setTimeSubmitted(CommonUtil.getUTCNow());
        taskHeader.setTimeCompleted(null);
        taskHeader.setStartMillis(CommonUtil.getEpochMilli(taskHeader.getTimeSubmitted()));
        taskHeader.setEndMillis(null);
        taskHeader.setProcessStatus(String.valueOf(ProcessStatus.Submitted));
        return taskHeaderRepo.save(taskHeader);
    }

    private String getTaskAJsonInputFilePath(String inputPath, String submissionDir) {
        TaskAInputDTO taskAInputDTO = new TaskAInputDTO();
        taskAInputDTO.setWfContainerATaskADataInput(inputPath);
        return CommonUtil.writePOJO2File(taskAInputDTO, submissionDir + "/" + "taskAInput.json");
    }

    @Scheduled(fixedRate = 10000)
    public void monitoring() {
        final String methodName = "monitoring():";
        if (debug_monitoring) {
            debug_monitoring = false;
            LOGGER.info("{} started at {}", methodName, CommonUtil.getTimeStamps(new SimpleDateFormat("MM/dd/yyyy HH:mm:ss")));
        }
        monitorTask();
        //monitorTaskHeader();
    }

    private void monitorTask() {
        final String methodName = "monitorTask():";
        // if succeeded, retrieve output, reset completed, time
        // if failed, reset
        List<Task> runningTasks = taskRepo.findDistinctByCompletedAndProcessStatus(false, String.valueOf(ProcessStatus.Submitted));
        if (runningTasks == null || runningTasks.isEmpty()) {
            return;
        }
        LOGGER.info("{} {} running tasks found", methodName, runningTasks.size());
        for (Task task : runningTasks) {
            CPJob cpJob = getCPJob(task);
            if (cpJob == null) {
                continue;
            }
            if (wasJobFinished(cpJob)) {
                task.setProcessStatus(cpJob.getStatus());
                task.setCompleted(true);
                task.setTimeCompleted(CommonUtil.getUTCNow());
                task.setEndMillis(CommonUtil.getEpochMilli(task.getTimeCompleted()));
                task.setResultOutput(getTaskResultOutput(task));
                taskRepo.save(task);
                resetSubsequentTasksOnError(task);
                submitSubsequentTasksOnSuccess(task);
            }
        }
    }

    private CPJob getCPJob(Task task) {
        if (CommonUtil.isNullOrEmpty(task.getCromwellId())) {
            return null;
        }
        ResponseEntity<?> responseEntity = cloudyPipelinesHttpClient.getStatusStringByCromwellId(task.getCromwellId());
        String body = responseEntity.getBody().toString();
        if (body == null) {
            return null;
        }
        return CommonUtil.json2POJO(body, CPJob.class);
    }

    private boolean wasJobFinished(CPJob cpJob) {
        String status = cpJob.getStatus().toLowerCase();
        if (status.contains(ProcessStatus.Failed.toString().toLowerCase())) {
            return true;
        }
        if (status.contains(ProcessStatus.Aborted.toString().toLowerCase())) {
            return true;
        }
        return status.contains(ProcessStatus.Succeeded.toString().toLowerCase());
    }

    private boolean taskFailedOrAborted(Task task) {
        String status = task.getProcessStatus().toLowerCase();
        if (status.contains(ProcessStatus.Failed.toString().toLowerCase())) {
            return true;
        }
        return status.contains(ProcessStatus.Aborted.toString().toLowerCase());
    }

    private String getTaskResultOutput(Task task) {
        final String methodName = "getTaskResultOutput():";
        String cpStatus = task.getProcessStatus().toLowerCase();
        if (!cpStatus.contains(ProcessStatus.Succeeded.toString().toLowerCase())) {
            return "";
        }
        ResponseEntity<?> responseEntity = cloudyPipelinesHttpClient.getOutputStringlByCromwellId(task.getCromwellId());
        if (responseEntity == null || responseEntity.getBody() == null) {
            LOGGER.error("{} httpResponse is null for {}: taskId={}, taskLabel={}", methodName, task.getProcessStatus(), task.getTaskId(), task.getLabel());
            return "";
        }
        return CommonUtil.parseCromwellSingleOutput(responseEntity.getBody().toString());
    }

    private void resetSubsequentTasksOnError(Task task) {
        if (!taskFailedOrAborted(task)) {
            return;
        }
        List<Task> subsequentTasks = taskRepo.findDistinctByTaskHeaderIdAndTaskIndexGreaterThan(task.getTaskHeaderId(), task.getTaskIndex());
        if (subsequentTasks == null) {
            return;
        }
        for (Task nextTask : subsequentTasks) {
            nextTask.setCompleted(true);
            nextTask.setProcessStatus(String.valueOf(ProcessStatus.Cancel));
            nextTask.setTimeSubmitted(null);
            nextTask.setTimeCompleted(null);
            nextTask.setStartMillis(null);
            nextTask.setEndMillis(null);
            nextTask.setNote("Cancelled: previous task(s) failed or aborted");
            taskRepo.save(nextTask);
        }
    }

    private void submitSubsequentTasksOnSuccess(Task task) {
        if (taskFailedOrAborted(task)) {
            return;
        }
        List<Task> subsequentTasks = taskRepo.findDistinctByTaskHeaderIdAndTaskIndex(task.getTaskHeaderId(), task.getTaskIndex() + 1);
        if (subsequentTasks == null || subsequentTasks.isEmpty()) {
            return;
        }
        //TODO: only deal with one task here
        Task nextTask = subsequentTasks.get(0);
        // keep ?????
    }

}

