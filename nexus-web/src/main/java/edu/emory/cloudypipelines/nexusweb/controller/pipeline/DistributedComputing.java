package edu.emory.cloudypipelines.nexusweb.controller.pipeline;

import edu.emory.cloudypipelines.nexusweb.bean.*;
import edu.emory.cloudypipelines.nexusweb.bean.generated.TaskAInputDTO;
import edu.emory.cloudypipelines.nexusweb.bean.generated.TaskBInputDTO;
import edu.emory.cloudypipelines.nexusweb.bean.generated.TaskCInputDTO;
import edu.emory.cloudypipelines.nexusweb.controller.ControllerUtil;
import edu.emory.cloudypipelines.nexusweb.db.entity.AppConfig;
import edu.emory.cloudypipelines.nexusweb.db.entity.Task;
import edu.emory.cloudypipelines.nexusweb.db.entity.TaskHeader;
import edu.emory.cloudypipelines.nexusweb.db.repo.AppConfigRepo;
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
    private static final Logger LOGGER = LoggerFactory.getLogger(DistributedComputing.class);
    private static final String WF_NAME = "DistributedComputingPOC";
    private static final String WF_VERSION_1 = "v1";
    private final String submissionRootDir = "/tmp/nexus-web/dc";

    @Autowired
    AppConfigRepo appConfigRepo;
    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;
    @Autowired
    TaskHeaderRepo taskHeaderRepo;
    @Autowired
    TaskRepo taskRepo;
    private boolean debug_monitoring = true;

    @RequestMapping(value = "/" + WF_VERSION_1, method = RequestMethod.POST)
    @ApiOperation(value = "Run DistributedComputingPOC: " + "/" + WF_VERSION_1)
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 404, message = "Not found", response = String.class)})
    public ResponseEntity<?> submitAndRun(
            @ModelAttribute("commonRequest") CommonRequest commonRequest,
            @ApiParam(name = "inputPath", value = "full path of image(s)") @RequestParam(value = "inputPath") String inputPath) {

        LOGGER.info("submitAndRun(): received workflowRunRequest={}, inputPath={}", commonRequest, inputPath);
        return submitMultiEnv(commonRequest, inputPath);
    }

    @RequestMapping(value = "/" + WF_VERSION_1 + "/{taskHeaderId}", method = RequestMethod.GET)
    @ApiOperation(value = "Get task metadata by taskHeaderId: " + "/" + WF_VERSION_1 + "/{taskHeaderId}")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 404, message = "Not found", response = String.class)})
    public ResponseEntity<?> getTaskMetadataByTaskHeaderId(
            @ApiParam(name = "taskHeaderId", value = "taskHeaderId", required = true) @PathVariable(name = "taskHeaderId", value = "taskHeaderId", required = true) String taskHeaderId) {

        LOGGER.info("getTaskMetadataByTaskHeaderId(): received taskHeaderId={}", taskHeaderId);
        SubmissionMetadata submissionMetadata = new SubmissionMetadata();
        TaskHeader taskHeader = taskHeaderRepo.findDistinctByTaskHeaderId(UUID.fromString(taskHeaderId));
        if (taskHeader == null) {
            return ControllerUtil.notFound(taskHeaderId + " Not Found");
        }
        submissionMetadata.setTaskHeader(taskHeader);
        List<Task> tasks = taskRepo.findDistinctByTaskHeaderId(UUID.fromString(taskHeaderId));
        submissionMetadata.setTasks(tasks);
        return ControllerUtil.OK(submissionMetadata);
    }

    private ResponseEntity<?> submitMultiEnv(CommonRequest commonRequest, String inputPath) {
        final String methodName = "submitMultiEnv();";
        //taskA: run containerA in bmicluster
        String submissionDir = CommonUtil.makeDestDirWithTimestamp(submissionRootDir);
        String wdlFilePath = CommonUtil.copyFileToDirectory(CONTAINER_A_WDL_PATH, submissionDir);
        String inputJsonFilePath = getTaskAJsonInputFilePath(inputPath, submissionDir);

        TaskHeader taskHeader = saveNewTaskHeader(inputPath, commonRequest);
        //submit the 1st task/job
        commonRequest.setLabel(composeTaskLabel(taskHeader.getTaskHeaderId(), "taskA", 0));

        ResponseEntity<RequestJobsResponseMsg> responseEntity = cloudyPipelinesHttpClient.submitByFilePath(commonRequest, wdlFilePath, inputJsonFilePath, null);
        if (!ControllerUtil.isHttpOk(responseEntity.getStatusCodeValue())) {
            return ControllerUtil.badRequest("Submission to CloudyPipelines Failed!");
        }

        TaskSubmissionResponse taskSubmissionResponse = postProcessMultiEnv(taskHeader, commonRequest, inputPath, responseEntity);
        if (taskSubmissionResponse.getTaskHeaderId() == null) {
            return ControllerUtil.badRequest("No header created, submission Failed");
        }
        if (taskSubmissionResponse.getTaskList().isEmpty()) {
            return ControllerUtil.badRequest("No tasks created, submission Failed!");
        }
        return ControllerUtil.OK(taskSubmissionResponse);
    }

    private TaskSubmissionResponse postProcessMultiEnv(TaskHeader taskHeader, CommonRequest commonRequest, String inputPath, ResponseEntity<RequestJobsResponseMsg> responseEntity) {

        UUID taskHeaderId = taskHeader.getTaskHeaderId();
        //details
        TaskSubmissionResponse taskSubmissionResponse = new TaskSubmissionResponse();
        taskSubmissionResponse.setTaskHeaderId(taskHeaderId);
        taskSubmissionResponse.setInputPath(inputPath);
        List<Task> tasks = saveNewTasks(taskHeader, commonRequest, inputPath, responseEntity);
        taskSubmissionResponse.setTaskList(buildTaskMetadataList(tasks));
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

    private List<Task> saveNewTasks(TaskHeader taskHeader, CommonRequest commonRequest, String inputPath, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
        List<Task> tasks = new ArrayList<>();
        //TODO will parse from the configuration file from user provides
        // for POC only
        Task task1 = buildTask1(taskHeader, responseEntity);
        if (task1 == null) {
            return tasks;
        }

        Task task2 = buildTask2(taskHeader);
        Task task3 = buildTask3(taskHeader);
        tasks.add(taskRepo.save(task1));
        tasks.add(taskRepo.save(task2));
        tasks.add(taskRepo.save(task3));
        return tasks;

    }

    private Task buildTask3(TaskHeader taskHeader) {
        Task task = buildTask2(taskHeader);
        task.setWfWdlFile(CONTAINER_C_WDL_PATH);
        task.setTaskIndex(2);
        task.setTaskName("taskC");
        task.setLabel(composeTaskLabel(taskHeader.getTaskHeaderId(), task.getTaskName(), task.getTaskIndex()));
        task.setProject("nexus-bmi");
        return task;
    }

    private Task buildTask2(TaskHeader taskHeader) {
        Task task = new Task();
        task.setTaskHeaderId(taskHeader.getTaskHeaderId());
        task.setWfWdlFile(CONTAINER_B_WDL_PATH);

        task.setRequestId("");
        task.setCromwellId("");
        task.setTaskIndex(1);
        task.setTaskName("taskB");
        task.setWfType(String.valueOf(WfType.WDL));
        task.setProcessStatus(String.valueOf(ProcessStatus.Waiting));
        task.setProject("cloudypipelines");
        task.setEmail("ping.gu@dbmi.emory.edu");
        task.setLabel(composeTaskLabel(taskHeader.getTaskHeaderId(), task.getTaskName(), task.getTaskIndex()));
        task.setRunningHoursAllowed(24);
        task.setPreemptibleOption(String.valueOf(PreemptibleOption.PREEMPTIBLE_STANDARD_ATTEMPT_BOTH));
        task.setTimeSubmitted(null);
        task.setTimeCompleted(null);
        task.setStartMillis(null);
        task.setEndMillis(null);
        return task;
    }

    //
    private Task buildTask1(TaskHeader taskHeader, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
        Task task = new Task();
        task.setTaskHeaderId(taskHeader.getTaskHeaderId());
        task.setWfWdlFile(CONTAINER_A_WDL_PATH);
        //TODO: how about json input file??
        RequestJobsResponseMsg requestJobsResponseMsg = responseEntity.getBody();
        if (requestJobsResponseMsg == null) {
            LOGGER.error("buildTask1(): CloudyPipelines requestJobsResponseMsg is null, something wrong");
            return null;
        }
        if (CommonUtil.isNullOrEmpty(requestJobsResponseMsg.getRequestId())) {
            LOGGER.error("buildTask1(): CloudyPipelines requestId is null, something wrong");
            return null;
        }
        task.setRequestId(requestJobsResponseMsg.getRequestId());
        List<CPJobStatus> cpJobStatuses = requestJobsResponseMsg.getJobStatusList();
        if (cpJobStatuses == null || cpJobStatuses.isEmpty()) {
            LOGGER.error("buildTask1(): CloudyPipelines requestJobsResponseMsg job list is null, something wrong");
            return null;
        }
        // should be only one
        task.setCromwellId(cpJobStatuses.get(0).getId());
        if (CommonUtil.isNullOrEmpty(task.getCromwellId())) {
            LOGGER.error("buildTask1(): CloudyPipelines cromwellId is null, something wrong");
            return null;
        }
        task.setTaskIndex(0);
        task.setTaskName("taskA");
        task.setWfType(String.valueOf(WfType.WDL));
        task.setProcessStatus(String.valueOf(ProcessStatus.Submitted));
        task.setProject("nexus-bmi");
        task.setEmail("ping.gu@dbmi.emory.edu");
        task.setLabel(composeTaskLabel(taskHeader.getTaskHeaderId(), task.getTaskName(), task.getTaskIndex()));
        task.setRunningHoursAllowed(24);
        task.setPreemptibleOption(String.valueOf(PreemptibleOption.PREEMPTIBLE_STANDARD_ATTEMPT_BOTH));
        task.setTimeSubmitted(CommonUtil.getUTCNow());
        task.setTimeCompleted(null);
        task.setStartMillis(CommonUtil.getEpochMilli(task.getTimeSubmitted()));
        task.setEndMillis(null);
        return task;
    }

    private String composeTaskLabel(UUID taskHeaderId, String taskName, Integer taskIndex) {
        return taskHeaderId.toString().substring(0, 8) + "_" + taskIndex + "_" + taskName;
    }

    private boolean updateTask(Task task, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
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

    private TaskHeader saveNewTaskHeader(String inputPath, CommonRequest commonRequest) {
        TaskHeader taskHeader = new TaskHeader();
        taskHeader.setCompleted(false);
        taskHeader.setInputPath(inputPath);
        taskHeader.setTimeSubmitted(CommonUtil.getUTCNow());
        taskHeader.setTimeCompleted(null);
        taskHeader.setStartMillis(CommonUtil.getEpochMilli(taskHeader.getTimeSubmitted()));
        taskHeader.setEndMillis(null);
        taskHeader.setProcessStatus(String.valueOf(ProcessStatus.Submitted));
        taskHeader.setLabel(commonRequest.getLabel());
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
        monitorTaskHeader();
    }

    private void monitorTaskHeader() {
        final String methodName = "monitorTaskHeader():";
        List<TaskHeader> headers = taskHeaderRepo.findDistinctByCompleted(false);
        if (headers == null || headers.isEmpty()) {
            return;
        }
        LOGGER.info("{} {} running taskHeaders found", methodName, headers.size());
        for (TaskHeader header : headers) {
            List<Task> tasks = taskRepo.findDistinctByTaskHeaderIdAndCompleted(header.getTaskHeaderId(), false);
            if (tasks != null && tasks.size() > 0) {
                continue;
            }
            header.setCompleted(true);
            header.setProcessStatus(String.valueOf(ProcessStatus.Completed));
            taskHeaderRepo.save(header);
        }
    }

    private void monitorTask() {
        final String methodName = "monitorTask():";

        List<Task> runningTasks = taskRepo.findDistinctByCompletedAndProcessStatus(false, String.valueOf(ProcessStatus.Submitted));
        if (runningTasks == null || runningTasks.isEmpty()) {
            return;
        }
        LOGGER.info("{} {} non finished tasks found", methodName, runningTasks.size());
        for (Task task : runningTasks) {
            CPJobStatus cpJobStatus = getCPJobStatus(task);
            if (cpJobStatus == null) {
                continue;
            }
            if (wasJobFinished(cpJobStatus)) {
                task.setProcessStatus(cpJobStatus.getStatus());
                task.setCompleted(true);
                task.setResultOutput(getTaskResultOutput(task));
                taskRepo.save(task);
                resetSubsequentTasksOnError(task);
                submitSubsequentTasksOnSuccess(task);
            }
        }
    }

    private CPJobStatus getCPJobStatus(Task task) {
        if (CommonUtil.isNullOrEmpty(task.getCromwellId())) {
            return null;
        }
        ResponseEntity<?> responseEntity = cloudyPipelinesHttpClient.getStatusStringByCromwellId(task.getCromwellId());
        String body = responseEntity.getBody().toString();
        if (body == null) {
            return null;
        }
        return CommonUtil.json2POJO(body, CPJobStatus.class);
    }

    private boolean wasJobFinished(CPJobStatus cpJobStatus) {
        String status = cpJobStatus.getStatus().toLowerCase();
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
            nextTask.setStartMillis(null);
            nextTask.setNote("Cancelled: previous task(s) failed or aborted");
            taskRepo.save(nextTask);
        }
    }

    private void submitSubsequentTasksOnSuccess(Task task) {
        final String methodName = "submitSubsequentTasksOnSuccess():";
        if (taskFailedOrAborted(task)) {
            return;
        }
        List<Task> subsequentTasks = taskRepo.findDistinctByTaskHeaderIdAndTaskIndex(task.getTaskHeaderId(), task.getTaskIndex() + 1);
        if (subsequentTasks == null || subsequentTasks.isEmpty()) {
            return;
        }
        //TODO: only deal with one task here
        Task nextTask = subsequentTasks.get(0);

        String submissionDir = CommonUtil.makeDestDirWithTimestamp(submissionRootDir);
        String wdlFilePath = CommonUtil.copyFileToDirectory(nextTask.getWfWdlFile(), submissionDir);
        String inputDataUrl = buildInputDataUrl(task);
        String inputJsonFilePath = buildJsonInputPath(nextTask, inputDataUrl, submissionDir);
        CommonRequest commonRequest = buildCommonRequest(nextTask);
        ResponseEntity<RequestJobsResponseMsg> responseEntity = cloudyPipelinesHttpClient.submitByFilePath(commonRequest, wdlFilePath, inputJsonFilePath, null);
        if (!ControllerUtil.isHttpOk(responseEntity.getStatusCodeValue())) {
            LOGGER.error("{} Submission to CloudyPipelines Failed for taskLabel={}", methodName, commonRequest.getLabel());
            nextTask.setCompleted(true);
            nextTask.setProcessStatus(String.valueOf(ProcessStatus.Failed));
            nextTask.setNote("Submission to CloudyPipelines Failed");
            taskRepo.save(nextTask);
            return;
        }
        updateTask(nextTask, responseEntity);
        taskRepo.save(nextTask);

    }

    private CommonRequest buildCommonRequest(Task task) {
        CommonRequest commonRequest = new CommonRequest();
        commonRequest.setRunningHoursAllowed(String.valueOf(task.getRunningHoursAllowed()));
        commonRequest.setProject(task.getProject());
        commonRequest.setLabel(task.getLabel());
        commonRequest.setEmail(task.getEmail());
        commonRequest.setPreemptibleOption(PreemptibleOption.valueOf(task.getPreemptibleOption()));
        commonRequest.setWorkflowType(WorkflowType.valueOf(task.getWfType()));
        return commonRequest;
    }

    private String buildInputDataUrl(Task task) {
        final String methodName = "buildInputDataUrl():";
        if (CommonUtil.isNullOrEmpty(task.getCromwellId()) ||
                CommonUtil.isNullOrEmpty(task.getRequestId()) ||
                CommonUtil.isNullOrEmpty(task.getResultOutput())) {
            LOGGER.error("{} Unable to buildInputDataUrl from taskName={}, taskId={}, taskHeaderId={}", methodName, task.getTaskName(), task.getTaskId(), task.getTaskHeaderId());
            return "";
        }
        String name = String.format("%s-file-download-url", task.getProject());
        AppConfig appConfig = appConfigRepo.findDistinctByName(name);
        if (appConfig == null || CommonUtil.isNullOrEmpty(appConfig.getValue())) {
            LOGGER.error("{} Unable to find url for name={} in appConfig", methodName, name);
            return "";
        }
        String pattern = appConfig.getValue();
        if (CommonUtil.isNullOrEmpty(pattern)) {
            return "";
        }
        return pattern.replaceAll("CROMWELL_ID", task.getCromwellId()).replaceAll("REQUEST_ID", task.getRequestId());
    }

    private String buildJsonInputPath(Task nextTask, String inputDataUrl, String destDir) {
        String jsonInputText = getTaskJsonInputText(nextTask, inputDataUrl);
        return CommonUtil.copyTextToFile(jsonInputText, destDir + "/" + nextTask.getTaskName() + ".json");
    }

    private String getTaskJsonInputText(Task nextTask, String inputDataUrl) {
        if (nextTask.getTaskIndex() == 1) {
            TaskBInputDTO taskBInputDTO = new TaskBInputDTO();
            taskBInputDTO.setWfContainerBTaskBFileTransferDataInputUrl(inputDataUrl);
            return CommonUtil.POJO2Json(taskBInputDTO);

        } else if (nextTask.getTaskIndex() == 2) {
            TaskCInputDTO taskCInputDTO = new TaskCInputDTO();
            taskCInputDTO.setWfContainerCTaskCFileTransferDataInputUrl(inputDataUrl);
            return CommonUtil.POJO2Json(taskCInputDTO);
        }
        return "";
    }


}

