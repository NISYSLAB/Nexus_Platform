package edu.emory.cloudypipelines.nexusweb.controller.pipeline;

import edu.emory.cloudypipelines.nexusweb.bean.CommonRequest;
import edu.emory.cloudypipelines.nexusweb.bean.generated.TaskAInputDTO;
import edu.emory.cloudypipelines.nexusweb.service.CloudyPipelinesHttpClient;
import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import io.swagger.annotations.*;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.text.SimpleDateFormat;

@RestController
@RequestMapping("/api/registered/DistributedComputing")
@Api(tags = "API > DistributedComputingPOC")
public class DistributedComputing {

    private static final Logger LOGGER = LoggerFactory.getLogger(Dicom2nifti.class);
    private static final String WF_NAME = "DistributedComputingPOC";
    private static final String WF_VERSION_1 = "v1";
    private final String submissionRootDir = "/tmp/nexusweb/dc";

    public static final String CONTAINER_A_WDL_PATH = "/Users/anniegu/workspace/Nexus_Platform/nexus-web/poc_workflow/containerA.wdl";
    public static final String CONTAINER_B_WDL_PATH = "/Users/anniegu/workspace/Nexus_Platform/nexus-web/poc_workflow/containerB.wdl";
    public static final String CONTAINER_C_WDL_PATH = "/Users/anniegu/workspace/Nexus_Platform/nexus-web/poc_workflow/containerC.wdl";

    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;

    @RequestMapping(value = "/" + WF_VERSION_1, method = RequestMethod.POST)
    @ApiOperation(value = "Run DistributedComputingPOC: " + WF_NAME + "/" + WF_VERSION_1)
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 404, message = "Not found", response = String.class)})
    public ResponseEntity<?> submitAndRun(
            @ModelAttribute("commonRequest") CommonRequest commonRequest,
            @ApiParam(name = "inputPath", value = "full path of image(s)", required = true) @RequestParam(value = "inputPath", required = true) String  inputPath) {

        LOGGER.info("submitAndRun(): received workflowRunRequest={}, inputPath={}", commonRequest, inputPath);
        return submitMultiEnv(commonRequest, inputPath);
    }

    private ResponseEntity<?> submitMultiEnv(CommonRequest commonRequest, String inputPath) {
        final String methodName = "submitMultiEnv();";
        //stepA: run containerA in bmicluster
        String submissionDir = CommonUtil.makeDestDirWithTimestamp(submissionRootDir);
        String wdlFilePath = CommonUtil.copyFileToDirectory(CONTAINER_A_WDL_PATH, submissionDir);
        String inputJsonFilePath = getTaskAJsonInputFilePath(inputPath, submissionDir);
        return cloudyPipelinesHttpClient.submitByFilePath(commonRequest, wdlFilePath, inputJsonFilePath, null);
        //stepB: run containerB in CloudyPipelines
        //stepC: run containerC in bmicluster
    }

    private String getTaskAJsonInputFilePath(String inputPath, String submissionDir) {
        TaskAInputDTO taskAInputDTO = new TaskAInputDTO();
        taskAInputDTO.setWfContainerATaskADataInput(inputPath);
        return CommonUtil.writePOJO2File(taskAInputDTO, submissionDir + "/" + "taskAInput.json");
    }

    @Scheduled(fixedRate = 10000)
    public void monitoring() {
        final String methodName = "monitoring():";
        LOGGER.info("{} started at {}", methodName, CommonUtil.getTimeStamps(new SimpleDateFormat("MM/dd/yyyy HH:mm:ss")));
    }
}

