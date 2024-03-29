package edu.emory.cloudypipelines.nexusweb.service;

import edu.emory.cloudypipelines.nexusweb.bean.CommonRequest;
import edu.emory.cloudypipelines.nexusweb.bean.RequestJobsResponseMsg;
import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import java.io.File;

@Component
public class CloudyPipelinesHttpClient {
    public static final String VERSION_V1 = "v1";
    public static final String VERSION_V11 = "v1.1";
    private static final Logger LOGGER = LoggerFactory.getLogger(CloudyPipelinesHttpClient.class);

    @Autowired
    RestTemplate cpRestTemplate;
    @Value("${AUTH_TOKEN}")
    private String AUTH_TOKEN;
    @Value("${cloudypipelines_url}")
    private String API_HOST;
    private String SUBMISSION_V1_URL = String.format("%s/api/workflows/%s", API_HOST, VERSION_V1);
    private String SUBMISSION_V11_URL = String.format("%s/api/workflows/%s", API_HOST, VERSION_V11);

    @Bean(name = "cpRestTemplate")
    public RestTemplate restTemplate(RestTemplateBuilder restTemplateBuilder) {
        return restTemplateBuilder.errorHandler(new RestTemplateResponseErrorHandler()).build();
    }

    @PostConstruct
    void init() {
        final String methodName = "init():";

        SUBMISSION_V1_URL = String.format("%s/api/workflows/%s", API_HOST, VERSION_V1);
        SUBMISSION_V11_URL = String.format("%s/api/workflows/%s", API_HOST, VERSION_V11);
        LOGGER.info("{} cloudypipelines_url={}", methodName, API_HOST);
        LOGGER.info("{} SUBMISSION_V1_URL={}", methodName, SUBMISSION_V1_URL);
        LOGGER.info("{} SUBMISSION_V11_URL={}", methodName, SUBMISSION_V11_URL);

        // testing
        String cromwellId = "2208acca-9e69-4f33-84fa-e6ca90e550bf";
        //LOGGER.info("{} getLogsUrlsById={}", methodName, cromwellId);
        //LOGGER.info("{} {}", methodName, getLogStringByCromwellId(cromwellId));
        // LOGGER.info("{} {}", methodName, getStatusStringByCromwellId(cromwellId));
        //LOGGER.info("{} {}", methodName, getOutputStringlByCromwellId(cromwellId));
        // LOGGER.info("{} {}", methodName, getMetadataStringByCromwellId(cromwellId));
    }

    public ResponseEntity<RequestJobsResponseMsg> submitV1(CommonRequest commonRequest,
                                                           MultipartFile workflowSource,
                                                           MultipartFile workflowInputs) {
        return submit(commonRequest, workflowSource, workflowInputs, null);
    }

    public ResponseEntity<RequestJobsResponseMsg> submitV11(CommonRequest commonRequest,
                                                            MultipartFile workflowSource,
                                                            MultipartFile workflowInputs,
                                                            MultipartFile workflowOptions) {
        return submit(commonRequest, workflowSource, workflowInputs, workflowOptions);
    }

    public ResponseEntity<RequestJobsResponseMsg> submit(CommonRequest commonRequest,
                                                         MultipartFile workflowSource,
                                                         MultipartFile workflowInputs,
                                                         MultipartFile workflowOptions) {
        final String methodName = "submit():";
        String submitDir = CommonUtil.makeDestDirWithTimestamp(CommonHttpClient.submissionRootDir);
        String wdlFilePath = CommonUtil.saveUploadedFile(workflowSource, submitDir);
        String inputsFilePath = CommonUtil.saveUploadedFile(workflowInputs, submitDir);
        String optionsFilePath = CommonUtil.saveUploadedFile(workflowOptions, submitDir);
        LOGGER.info("{} submitDir={}, inputsFilePath={}, wdfFilePath={}, optionsFilePath={}", methodName, submitDir, inputsFilePath, wdlFilePath, optionsFilePath);
        return submitByFilePath(commonRequest, wdlFilePath, inputsFilePath, optionsFilePath);
    }

    public ResponseEntity<RequestJobsResponseMsg> submitByFilePath(CommonRequest commonRequest,
                                                                   String wdlFilePath,
                                                                   String inputsFilePath,
                                                                   String optionsFilePath) {
        final String methodName = "submitByFilePath():";

        //TODO: toke should be replaced with individual
        HttpEntity<LinkedMultiValueMap<String, Object>> requestEntity = buildSubmissionHttpEntity(
                wdlFilePath,
                inputsFilePath,
                optionsFilePath,
                commonRequest,
                AUTH_TOKEN
        );

        String whichUri = SUBMISSION_V11_URL;
        if (StringUtils.isBlank(optionsFilePath)) {
            whichUri = SUBMISSION_V1_URL;
        }
        LOGGER.info("{} requestEntity={}", methodName, requestEntity);
        LOGGER.info("{} whichUri={}", methodName, whichUri);
        return cpRestTemplate.exchange(whichUri, HttpMethod.POST, requestEntity, new ParameterizedTypeReference<RequestJobsResponseMsg>() {
        });
    }

    ResponseEntity<RequestJobsResponseMsg> submitRegisteredWorkflow(CommonRequest commonRequest,
                                                                    String wfName,
                                                                    String wfVersion,
                                                                    MultipartFile workflowInputs,
                                                                    MultipartFile workflowOptions) {
        final String methodName = "submitRegisteredWorkflow():";
        String submitDir = CommonUtil.makeDestDirWithTimestamp(CommonHttpClient.submissionRootDir);
        String inputsFilePath = CommonUtil.saveUploadedFile(workflowInputs, submitDir);
        String optionsFilePath = CommonUtil.saveUploadedFile(workflowOptions, submitDir);
        LOGGER.info("{} submitDir={}, wfName={}, wfVersion={},inputsFilePath={}, optionsFilePath={}", methodName, submitDir, wfName, wfVersion, inputsFilePath, optionsFilePath);

        //TODO: toke should be replaced with individual
        HttpEntity<LinkedMultiValueMap<String, Object>> requestEntity = buildSubmissionHttpEntity(
                "",
                inputsFilePath,
                optionsFilePath,
                commonRequest,
                AUTH_TOKEN
        );

        String whichUri = String.format("%s/api/registered/workflowpipelines/%s/%s/", API_HOST, wfName, wfVersion);
        LOGGER.info("{} requestEntity={}", methodName, requestEntity);
        LOGGER.info("{} whichUri={}", methodName, whichUri);
        return cpRestTemplate.exchange(whichUri, HttpMethod.POST, requestEntity, new ParameterizedTypeReference<RequestJobsResponseMsg>() {
        });
    }

    private HttpEntity<LinkedMultiValueMap<String, Object>>
    buildSubmissionHttpEntity(String wdlFilePath, String inputsFilePath, String optionsFilePath, CommonRequest commonRequest, String authToken) {
        LinkedMultiValueMap<String, Object> map = new LinkedMultiValueMap<>();

        if (StringUtils.isNoneEmpty(wdlFilePath)) {
            map.add("workflowSource", new FileSystemResource(new File(wdlFilePath)));
        }
        if (StringUtils.isNoneEmpty(inputsFilePath)) {
            map.add("workflowInputs", new FileSystemResource(new File(inputsFilePath)));
            map.add("jsonInputFile", new FileSystemResource(new File(inputsFilePath)));
        }
        if (StringUtils.isNoneEmpty(optionsFilePath)) {
            map.add("workflowOptions", new FileSystemResource(new File(optionsFilePath)));
        }

        map.add("email", commonRequest.getEmail());
        map.add("label", commonRequest.getLabel());
        map.add("preemptibleOption", commonRequest.getPreemptibleOption().toString());
        map.add("project", commonRequest.getProject());
        map.add("projectName", commonRequest.getProject());
        map.add("runningHoursAllowed", commonRequest.getRunningHoursAllowed());
        map.add("workflowType", commonRequest.getWorkflowType().toString());

        HttpHeaders headers = getAuthHeaders(authToken);
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        return new HttpEntity<>(map, headers);
    }

    public ResponseEntity<?> abortByCromwellId(String cromwellId) {
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/v1/{cromwellId}/abort"
        String apiUrl = String.format("%s/api/workflows/v1/%s/abort", API_HOST, cromwellId);
        return cpRestTemplate.exchange(apiUrl,
                HttpMethod.POST,
                new HttpEntity<>(getHttpRequestEmptyMap(), getAuthHeaders(AUTH_TOKEN)),
                new ParameterizedTypeReference<String>() {
                });
    }

    public ResponseEntity<?> getWorkflowLogs(String cromwellId) {
        final String methodName = "getWorkflowLogs():";

        LOGGER.info("{} call CloudyPipelines for cromwellId={}", methodName, cromwellId);
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/VERSION/{cromwellId}/logs"
        String apiUrl = String.format("%s/api/workflows/%s/%s/logs", API_HOST, VERSION_V1, cromwellId);
        return getHttpString(apiUrl);
    }

    public ResponseEntity<?> getStatusStringByCromwellId(String cromwellId) {
        final String methodName = "getStatusStringByCromwellId():";
        LOGGER.info("{} call CloudyPipelines for cromwellId={}", methodName, cromwellId);
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/VERSION/{cromwellId}/status"
        String apiUrl = String.format("%s/api/workflows/%s/%s/status", API_HOST, VERSION_V1, cromwellId);
        return getHttpString(apiUrl);
    }

    public ResponseEntity<?> getOutputStringlByCromwellId(String cromwellId) {
        final String methodName = "getOutputStringlByCromwellId():";
        LOGGER.info("{} call cloudyPipelines for cromwellId={}", methodName, cromwellId);
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/VERSION/{cromwellId}/outputs"
        String apiUrl = String.format("%s/api/workflows/%s/%s/outputs", API_HOST, VERSION_V1, cromwellId);
        return getHttpString(apiUrl);
    }

    public ResponseEntity<?> getMetadataStringByCromwellId(String cromwellId) {
        final String methodName = "getMetadataStringByCromwellId():";
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/version/{cromwellId}/metadata"
        String apiUrl = String.format("%s/api/workflows/%s/%s/metadata", API_HOST, VERSION_V1, cromwellId);
        return getHttpString(apiUrl);
    }

    public ResponseEntity<?> submitRegisteredWorkflow(CommonRequest commonRequest, String wfName, String wfVersion, MultipartFile jsonInputFile) {
        return submitRegisteredWorkflow(commonRequest, wfName, wfVersion, jsonInputFile, null);
    }

    public ResponseEntity<String> getHttpString(String apiUrl) {
        return callGetHttp(apiUrl);
    }

    public ResponseEntity<String> callGetHttp(String apiUrl) {
        try {
            return cpRestTemplate.exchange(
                    apiUrl,
                    HttpMethod.GET,
                    new HttpEntity<>(getHttpRequestEmptyMap(), getAuthHeaders(AUTH_TOKEN)),
                    new ParameterizedTypeReference<String>() {
                    });

        } catch (Exception e) {
            LOGGER.error("callGetHttp(): apiUrl={}, Exception: {}", apiUrl, e.getMessage());
            return new ResponseEntity<>("Bad Request", HttpStatus.BAD_REQUEST);
        }
    }

    LinkedMultiValueMap<String, Object> getHttpRequestEmptyMap() {
        LinkedMultiValueMap<String, Object> map = new LinkedMultiValueMap<>();
        return map;
    }

    HttpHeaders getAuthHeaders(String authToken) {
        HttpHeaders headers = new HttpHeaders();
        String oAuth = "OAuth " + authToken;
        headers.add("Authorization", oAuth);
        return headers;
    }

}
