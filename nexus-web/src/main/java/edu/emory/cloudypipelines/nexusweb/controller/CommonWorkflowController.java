package edu.emory.cloudypipelines.nexusweb.controller;

import edu.emory.cloudypipelines.nexusweb.bean.CommonRequest;
import edu.emory.cloudypipelines.nexusweb.bean.RequestJobsResponseMsg;
import edu.emory.cloudypipelines.nexusweb.service.CloudyPipelinesHttpClient;
import edu.emory.cloudypipelines.nexusweb.service.CommonHttpClient;
import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import io.swagger.annotations.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/workflows")
@Api(tags = "Common Workflow Pipeline APIs - submit, query, abort workflow pipeline")
public class CommonWorkflowController {
    public static final String VERSION_V1 = "v1";
    public static final String VERSION_V11 = "v1.1";
    private static final Logger LOGGER = LoggerFactory.getLogger(CommonWorkflowController.class);

    @Autowired
    CommonHttpClient commonHttpClient;

    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;

    @ApiOperation(value = "Submit workflow pipeline with WDL File, inputs JSON File, the inputs JSON will be an array of objects ")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = RequestJobsResponseMsg.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class)})
    @PostMapping("/" + VERSION_V1)
    public ResponseEntity<RequestJobsResponseMsg> submitV1(
            @ModelAttribute("commonRequest") CommonRequest commonRequest,
            @ApiParam(name = "workflowSource", value = "WDL or CWL file", required = true) @RequestParam(value = "workflowSource", required = true) MultipartFile workflowSource,
            @ApiParam(name = "workflowInputs", value = "JSON or YAML file containing inputs as an array of objects", required = true) @RequestParam(value = "workflowInputs") MultipartFile workflowInputs) {

        return cloudyPipelinesHttpClient.submitV1(commonRequest, workflowSource, workflowInputs);
    }

    @ApiOperation(value = "Submit workflow pipeline with WDL File, inputs JSON File and workflow options file, the inputs JSON will be an array of objects ")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = RequestJobsResponseMsg.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class)})
    @PostMapping("/" + VERSION_V11)
    public ResponseEntity<RequestJobsResponseMsg> submitV11(
            @ModelAttribute("commonRequest") CommonRequest commonRequest,
            @ApiParam(name = "workflowSource", value = "WDL or CWL file", required = true) @RequestParam(value = "workflowSource", required = true) MultipartFile workflowSource,
            @ApiParam(name = "workflowInputs", value = "JSON or YAML file containing inputs as an array of objects", required = true) @RequestParam(value = "workflowInputs") MultipartFile workflowInputs,
            @ApiParam(name = "workflowOptions", value = "workflow options file", required = true) @RequestParam(value = "workflowOptions", required = true) MultipartFile workflowOptions) {

        return cloudyPipelinesHttpClient.submitV11(commonRequest, workflowSource, workflowInputs, workflowOptions);
    }

    @ApiOperation(value = "Abort workflow by workflowId")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class)})
    @PostMapping("/" + VERSION_V1 + "/abort/{workflowId}")
    public ResponseEntity<?> abortByCromwellId(@PathVariable(required = true) String workflowId, @RequestParam(value = "email", required = true) String email) {
        final String methodName = "abortByCromwellId()";
        //TODO: valid email
        LOGGER.info("{} workflowId={}", methodName, workflowId);
        if (CommonUtil.isNullOrEmpty(workflowId)) {
            LOGGER.info("{} workflowId is null or empty, unable to call API", methodName);
            return ControllerUtil.badRequest("workflowId: " + workflowId + " not found");
        }
        return cloudyPipelinesHttpClient.abortByCromwellId(workflowId);
    }

    @ApiOperation(value = "Get workflow metadata by workflowId")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad Request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)
    })
    @GetMapping("/" + VERSION_V1 + "/metadata/{workflowId}")
    public ResponseEntity<?> getWorkflowMetadataByUid(@PathVariable(required = true) String workflowId) {
        final String methodName = "getWorkflowMetadataByUid{}:";
        LOGGER.info("{} workflowId={}", methodName, workflowId);
        if (CommonUtil.isNullOrEmpty(workflowId)) {
            LOGGER.info("{} workflowId is null or empty, unable to call API", methodName);
            return ControllerUtil.badRequest("workflowId: " + workflowId + " not found");
        }
        return cloudyPipelinesHttpClient.getMetadataStringByCromwellId(workflowId);
    }

    @ApiOperation(value = "Get workflow logs by workflowId")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad Request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)
    })
    @GetMapping("/" + VERSION_V1 + "/logs/{workflowId}")
    public ResponseEntity<?> getWorkflowLogs(@PathVariable(required = true) String workflowId) {
        final String methodName = "getWorkflowLogs{}:";
        LOGGER.info("{} workflowId={}", methodName, workflowId);
        if (CommonUtil.isNullOrEmpty(workflowId)) {
            LOGGER.info("{} workflowId is null or empty, unable to call API", methodName);
            return ControllerUtil.badRequest("workflowId: " + workflowId + " not found");
        }
        return cloudyPipelinesHttpClient.getWorkflowLogs(workflowId);
    }

    @ApiOperation(value = "Get workflow status by workflowId")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad Request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)
    })
    @GetMapping("/" + VERSION_V1 + "/status/{workflowId}")
    public ResponseEntity<?> getStatusStringByCromwellId(@PathVariable(required = true) String workflowId) {
        final String methodName = "getStatusStringByCromwellId{}:";
        LOGGER.info("{} workflowId={}", methodName, workflowId);
        if (CommonUtil.isNullOrEmpty(workflowId)) {
            LOGGER.info("{} workflowId is null or empty, unable to call API", methodName);
            return ControllerUtil.badRequest("workflowId: " + workflowId + " not found");
        }
        return cloudyPipelinesHttpClient.getStatusStringByCromwellId(workflowId);
    }

    @ApiOperation(value = "Get workflow outputs by workflowId")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad Request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)
    })
    @GetMapping("/" + VERSION_V1 + "/outputs/{workflowId}")
    public ResponseEntity<?> getOutputStringlByCromwellId(@PathVariable(required = true) String workflowId) {
        final String methodName = "getOutputStringlByCromwellId{}:";
        LOGGER.info("{} workflowId={}", methodName, workflowId);
        if (CommonUtil.isNullOrEmpty(workflowId)) {
            LOGGER.info("{} workflowId is null or empty, unable to call API", methodName);
            return ControllerUtil.badRequest("workflowId: " + workflowId + " not found");
        }
        return cloudyPipelinesHttpClient.getOutputStringlByCromwellId(workflowId);
    }

}
