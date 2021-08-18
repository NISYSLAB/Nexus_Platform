package edu.emory.cloudypipelines.nexusweb.controller;

import edu.emory.cloudypipelines.nexusweb.bean.CommonRequest;
import edu.emory.cloudypipelines.nexusweb.bean.RequestJobsResponseMsg;
import edu.emory.cloudypipelines.nexusweb.service.CloudyPipelinesHttpClient;
import io.swagger.annotations.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/workflows")
@Api(tags = "Common Workflow Pipeline APIs", value = "testValue", description = "submit, query, abort workflow pipeline")
public class CommonWorkflowController {
    public static final String VERSION_V1 = "v1";
    public static final String VERSION_V11 = "v1.1";
    private static final Logger LOGGER = LoggerFactory.getLogger(CommonWorkflowController.class);
    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;

    @ApiOperation(value = "Submit workflow pipeline with WDL File, inputs JSON File, the inputs JSON will be an array of objects ")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = RequestJobsResponseMsg.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class)})
    @PostMapping("/submission/" + VERSION_V1)
    public ResponseEntity<RequestJobsResponseMsg> submitV1(
            @ModelAttribute("commonRequest") CommonRequest commonRequest,
            @ApiParam(name = "workflowSource", value = "WDL or CWL file", required = true) @RequestParam(value = "workflowSource", required = true) MultipartFile workflowSource,
            @ApiParam(name = "workflowInputs", value = "JSON or YAML file containing inputs as an array of objects", required = true) @RequestParam(value = "workflowInputs") MultipartFile workflowInputs) {

        return cloudyPipelinesHttpClient.submitV1(commonRequest, workflowSource, workflowInputs);
    }
}
