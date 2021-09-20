package edu.emory.cloudypipelines.nexusweb.controller.pipeline;

import edu.emory.cloudypipelines.nexusweb.bean.*;
import edu.emory.cloudypipelines.nexusweb.bean.generated.SubmissionConfig;
import edu.emory.cloudypipelines.nexusweb.bean.generated.TaskListItem;
import edu.emory.cloudypipelines.nexusweb.controller.ControllerUtil;
import edu.emory.cloudypipelines.nexusweb.db.entity.AppConfig;
import edu.emory.cloudypipelines.nexusweb.db.entity.Task;
import edu.emory.cloudypipelines.nexusweb.db.entity.TaskFile;
import edu.emory.cloudypipelines.nexusweb.db.entity.TaskHeader;
import edu.emory.cloudypipelines.nexusweb.db.repo.AppConfigRepo;
import edu.emory.cloudypipelines.nexusweb.db.repo.TaskFileRepo;
import edu.emory.cloudypipelines.nexusweb.db.repo.TaskHeaderRepo;
import edu.emory.cloudypipelines.nexusweb.db.repo.TaskRepo;
import edu.emory.cloudypipelines.nexusweb.service.AsyncService;
import edu.emory.cloudypipelines.nexusweb.service.CloudyPipelinesHttpClient;
import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import io.swagger.annotations.*;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
    private static final String WF_VERSION_2 = "v2";
    public final String submissionRootDir = "/tmp/nexus-web/dc";

    @Autowired
    AppConfigRepo appConfigRepo;
    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;
    @Autowired
    TaskHeaderRepo taskHeaderRepo;
    @Autowired
    TaskRepo taskRepo;
    @Autowired
    TaskFileRepo taskFileRepo;
    @Autowired
    AsyncService asyncService;
    private boolean debug_monitoring = true;

    @RequestMapping(value = "/" + WF_VERSION_1, method = RequestMethod.POST)
    @ApiOperation(value = "Run DistributedComputingPOC: " + "/" + WF_VERSION_2)
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 404, message = "Not found", response = String.class)})
    public ResponseEntity<?> submitOnlineAndRunByConfigFile(
            @ApiParam(name = "email", value = "email", required = false) @RequestParam(value = "email") String email,
            @ApiParam(name = "label", value = "label", required = false) @RequestParam(value = "label") String label,
            @ApiParam(name = "inputPath", value = "inputPath", required = false) @RequestParam(value = "inputPath") String inputPath,
            @RequestParam(value = "configurationFile", required = true) MultipartFile configurationFile) {

        final String methodName = "submitOnlineAndRunByConfigFile():";
        LOGGER.info("submitAndRunByConfigFile(): received email={}, label={}", email, label);
        String configFilePath = uploadUserFile(configurationFile);
        SubmissionConfig submissionConfig = CommonUtil.readYaml2Pojo(configFilePath, SubmissionConfig.class);
        LOGGER.info("{} submissionConfig={}", methodName, submissionConfig);
        if (submissionConfig == null) {
            LOGGER.error("{} bad submissionConfig", methodName);
            return ControllerUtil.badRequest("Bad configurations");
        }
        // create TaskHeader
        if (StringUtils.isNotBlank(email)) {
            submissionConfig.setEmail(email.trim());
        }
        if (StringUtils.isNotBlank(label)) {
            submissionConfig.setLabel(label);
        }
        if (StringUtils.isNotBlank(inputPath)) {
            submissionConfig.setDataInput(inputPath.trim());
        }

        TaskHeader taskHeader = buildNewTaskHeader(submissionConfig);
        if (taskHeader == null) {
            LOGGER.error("{} unable to create taskHeader", methodName);
            return ControllerUtil.badRequest("Unable to create taskHeader");
        }

        List<Task> taskList = buildNewTaskList(taskHeader, submissionConfig);
        if (taskList == null || taskList.isEmpty()) {
            LOGGER.error("{} no task list created", methodName);
            deleteTaskHeader(taskHeader);
            return ControllerUtil.badRequest("No tasks created, might be bad configurations");
        }

        Task task = taskList.get(0);
        String submitDir = buildSubmissionDir();

        CommonRequest commonRequest = buildCommonRequest(task);
        String wdlFilePath = getWDLFilePath(task, submitDir + "/wf.wdl");
        if (CommonUtil.isNullOrEmpty(wdlFilePath)) {
            LOGGER.error("{} unable to find wdl file for taskIndex={}", methodName, 0);
            task.setNote("Unable to find wdl file");
            flagTaskError(taskHeader, task);
            return ControllerUtil.badRequest("Unable to locate/create wdl file for taskIndex: " + 0);
        }
        String inputJsonFilePath = getInputFilePath(task, submitDir + "/input.json", submissionConfig.getDataInput());
        if (CommonUtil.isNullOrEmpty(inputJsonFilePath)) {
            LOGGER.error("{} unable to find input file for taskIndex={}", methodName, 0);
            task.setNote("Unable to find input file ");
            flagTaskError(taskHeader, task);
            return ControllerUtil.badRequest("Unable to locate/create input file for taskIndex: " + 0);
        }

        ResponseEntity<RequestJobsResponseMsg> responseEntity = cloudyPipelinesHttpClient.submitByFilePath(commonRequest, wdlFilePath, inputJsonFilePath, null);
        if (!ControllerUtil.isHttpOk(responseEntity.getStatusCodeValue())) {
            task.setNote("Submission to CloudyPipelines Failed");
            flagTaskError(taskHeader, task);
            return ControllerUtil.badRequest("Submission to CloudyPipelines Failed!");
        }

        task = postProcessTask(task, responseEntity);
        if (taskFailedOrAborted(task)) {
            return ControllerUtil.badRequest("No tasks created, submission Failed!");
        }
        return ControllerUtil.OK(buildTaskSubmissionResponse(taskHeader, taskList));
    }

    private String buildSubmissionDir() {
        return CommonUtil.makeDestDirWithTimestamp(submissionRootDir + "/submit");
    }

    private void flagTaskError(TaskHeader taskHeader, Task task) {
        if (task != null) {
            task.setProcessStatus(String.valueOf(ProcessStatus.Failed));
            task.setCompleted(true);
            taskRepo.save(task);
            resetSubsequentTasksOnError(task);
        }
        if (taskHeader != null) {
            taskHeader.setCompleted(true);
            taskHeaderRepo.save(taskHeader);
        }
    }

    private void deleteTaskHeader(TaskHeader taskHeader) {
        taskHeaderRepo.delete(taskHeader);
    }

    private Task postProcessTask(Task task, ResponseEntity<RequestJobsResponseMsg> responseEntity) {
        RequestJobsResponseMsg requestJobsResponseMsg = responseEntity.getBody();
        if (requestJobsResponseMsg == null) {
            LOGGER.error("postProcessMultiEnv(): CloudyPipelines requestJobsResponseMsg is null, something wrong");
            task.setNote("CloudyPipelines requestJobsResponseMsg is null");
            flagTaskError(null, task);
            return task;
        }
        if (CommonUtil.isNullOrEmpty(requestJobsResponseMsg.getRequestId())) {
            LOGGER.error("postProcessMultiEnv(): CloudyPipelines requestId is null, something wrong");
            task.setNote("CloudyPipelines requestId is null");
            flagTaskError(null, task);
            return task;
        }

        List<CPJobStatus> cpJobStatuses = requestJobsResponseMsg.getJobStatusList();
        if (cpJobStatuses == null || cpJobStatuses.isEmpty()) {
            LOGGER.error("postProcessMultiEnv(): CloudyPipelines requestJobsResponseMsg job list is null, something wrong");
            task.setNote("CloudyPipelines requestJobsResponseMsg job list is null");
            flagTaskError(null, task);
            return task;
        }
        // should be only one
        task.setCromwellId(cpJobStatuses.get(0).getId());
        if (CommonUtil.isNullOrEmpty(task.getCromwellId())) {
            LOGGER.error("buildTask1(): CloudyPipelines cromwellId is null, something wrong");
            task.setNote("CloudyPipelines cromwellId is null");
            flagTaskError(null, task);
            return null;
        }
        task.setRequestId(requestJobsResponseMsg.getRequestId().trim());
        task.setProcessStatus(String.valueOf(ProcessStatus.Submitted));
        task.setTimeSubmitted(CommonUtil.getUTCNow());
        task.setTimeCompleted(null);
        task.setEndMillis(null);
        return taskRepo.save(task);
    }


    private TaskHeader buildNewTaskHeader(SubmissionConfig submissionConfig) {
        TaskHeader taskHeader = new TaskHeader();
        taskHeader.setLabel(submissionConfig.getLabel());
        taskHeader.setInputPath(submissionConfig.getDataInput());
        taskHeader.setCompleted(false);
        taskHeader.setProcessStatus(String.valueOf(ProcessStatus.Submitted));
        taskHeader.setTimeSubmitted(CommonUtil.getUTCNow());
        taskHeader.setStartMillis(CommonUtil.getEpochMilli(taskHeader.getTimeSubmitted()));
        taskHeader.setJsonConfig(CommonUtil.pojo2Json(submissionConfig));
        taskHeader.setYamlConfig(CommonUtil.pojo2Yaml(submissionConfig));
        return taskHeaderRepo.save(taskHeader);
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

    private TaskSubmissionResponse buildTaskSubmissionResponse(TaskHeader taskHeader, List<Task> tasks) {
        TaskSubmissionResponse taskSubmissionResponse = new TaskSubmissionResponse();
        taskSubmissionResponse.setTaskHeaderId(taskHeader.getTaskHeaderId());
        taskSubmissionResponse.setInputPath(taskHeader.getInputPath());
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

    private String composeTaskLabel(TaskHeader taskHeader, String taskName, Integer taskIndex) {
        return StringUtils.deleteWhitespace(taskHeader.getLabel() + "_" + taskHeader.getTaskHeaderId().toString().substring(0, 8) + "_" + taskIndex + "_" + taskName);
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
        return CommonUtil.json2Pojo(body, CPJobStatus.class);
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

    public void submitSubsequentTasksOnSuccess(Task task) {

        if (taskFailedOrAborted(task)) {
            return;
        }
        List<Task> subsequentTasks = taskRepo.findDistinctByTaskHeaderIdAndTaskIndex(task.getTaskHeaderId(), task.getTaskIndex() + 1);
        if (subsequentTasks == null || subsequentTasks.isEmpty()) {
            return;
        }
        //TODO: only deal with one task here
        Task nextTask = subsequentTasks.get(0);

        String submissionDir = buildSubmissionDir();
        String wdlFilePath = CommonUtil.copyTextToFile(nextTask.getWfWdlFile(), submissionDir + "/" + nextTask.getTaskName() + ".wdl");
        String inputDataUrl = buildInputDataUrl(task);
        if (inputDataUrl != null) {
            inputDataUrl = inputDataUrl.trim();
        }
        String inputJsonFilePath = buildJsonInputPath(nextTask, inputDataUrl, submissionDir);
        CommonRequest commonRequest = buildCommonRequest(nextTask);
        asyncService.submitNextAndUpdate(commonRequest, wdlFilePath, inputJsonFilePath, nextTask);
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
        return StringUtils.deleteWhitespace(pattern.replaceAll("CROMWELL_ID", task.getCromwellId()).replaceAll("REQUEST_ID", task.getRequestId()));
    }

    private String buildJsonInputPath(Task task, String inputDataUrl, String destDir) {
        String jsonInputText = task.getWfInputFile();
        if (jsonInputText != null) {
            jsonInputText = jsonInputText.replaceAll("dataInput_replaced", inputDataUrl).replaceAll("dataInputUrl_replaced", inputDataUrl).trim();
            task.setWfInputFile(jsonInputText);
        }
        return CommonUtil.copyTextToFile(jsonInputText, destDir + "/" + task.getTaskName() + ".json");
    }

    private String uploadUserFile(MultipartFile multipartFile) {
        String loadDir = buildUploadDir();
        return CommonUtil.saveUploadedFile(multipartFile, loadDir);
    }

    private String buildUploadDir() {
        return CommonUtil.makeDestDirWithTimestamp(submissionRootDir + "/upload");
    }

    private String getWDLFilePath(Task task, String destFilePath) {
        return CommonUtil.writeText2File(task.getWfWdlFile(), destFilePath);
    }

    private String getInputFilePath(Task task, String destFilePath, String dataInputPath) {
        String inputFileText = task.getWfInputFile();
        if (inputFileText != null) {
            inputFileText = inputFileText.replaceAll("dataInput_replaced", dataInputPath).replaceAll("dataInputUrl_replaced", dataInputPath).trim();
            task.setWfInputFile(inputFileText);
        }
        return CommonUtil.writeText2File(inputFileText, destFilePath);
    }

    private List<Task> buildNewTaskList(TaskHeader taskHeader, SubmissionConfig submissionConfig) {
        List<Task> tasks = new ArrayList<>();
        if (submissionConfig.getTaskList() == null) {
            return tasks;
        }
        for (TaskListItem item : submissionConfig.getTaskList()) {
            Task task = buildFromTaskItem(item, taskHeader, submissionConfig.getEmail());
            task.setCompleted(false);
            task.setProcessStatus(String.valueOf(ProcessStatus.Waiting));
            task.setTimeSubmitted(null);
            task.setStartMillis(CommonUtil.getEpochMilli(CommonUtil.getUTCNow()));
            tasks.add(taskRepo.save(task));
        }
        return tasks;
    }

    private Task buildFromTaskItem(TaskListItem item, TaskHeader taskHeader, String email) {
        Task task = new Task();
        task.setTaskName(item.getName().trim());
        task.setTaskIndex(item.getIndex());
        task.setWfWdlFile(getFileContent(item.getWdlFilePath()));
        task.setWfInputFile(getFileContent(item.getInputFilePath()));
        task.setWfOptionFile("");
        task.setTaskHeaderId(taskHeader.getTaskHeaderId());
        task.setWfType(item.getWorkflowType());
        task.setEmail(email);
        task.setRunningHoursAllowed(item.getRunningHoursAllowed());
        task.setPreemptibleOption(item.getPreemptibleOption());
        task.setProject(item.getProject());
        task.setLabel(composeTaskLabel(taskHeader, task.getTaskName(), task.getTaskIndex()));
        return task;
    }

    private String getFileContent(String filePath) {
        final String methodName = "getFileContent():";
        String[] splits = filePath.split(":");
        if (splits == null || splits.length < 2) {
            LOGGER.error("{} unable to parse {}", methodName, filePath);
            return "";
        }
        if (splits[0].trim().toUpperCase().startsWith("DB")) {
            String name = splits[1].trim();
            TaskFile taskFile = taskFileRepo.findDistinctByFileName(name);
            if (taskFile == null) {
                LOGGER.error("{} {} not found in db file table", methodName, name);
                return "";
            }
            String content = taskFile.getFileContent();
            if (content == null) {
                return "";
            }
            return content.trim();
        }
        return CommonUtil.readFile2Text(splits[1].trim());
    }
}

