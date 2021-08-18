package edu.emory.cloudypipelines.nexusweb.controller.pipeline;

import edu.emory.cloudypipelines.nexusweb.bean.CommonRequest;
import edu.emory.cloudypipelines.nexusweb.service.CloudyPipelinesHttpClient;
import io.swagger.annotations.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/registered/dicom2nifti")
@Api(tags = "API > DICOM2NIFTI")
public class Dicom2nifti {
    private static final Logger LOGGER = LoggerFactory.getLogger(Dicom2nifti.class);
    private static final String WF_NAME = "dicom2nifti";
    private static final String WF_VERSION_1 = "v1";

    @Autowired
    CloudyPipelinesHttpClient cloudyPipelinesHttpClient;

    @RequestMapping(value = "/" + WF_VERSION_1, method = RequestMethod.POST)
    @ApiOperation(value = "Run dicom2nifti: " + WF_NAME + "/" + WF_VERSION_1)
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 404, message = "Not found", response = String.class)})
    public ResponseEntity<?> submitAndRun(
            @ModelAttribute("commonRequest") CommonRequest commonRequest
            , @ApiParam(name = "jsonInputFile", value = "input json file", required = true) @RequestParam(value = "jsonInputFile", required = true) MultipartFile jsonInputFile) {
        LOGGER.info("submitAndRun(): received workflowRunRequest={}", commonRequest);
        return cloudyPipelinesHttpClient.submitRegisteredWorkflow(commonRequest, WF_NAME, WF_VERSION_1, jsonInputFile);
    }
}

