package edu.emory.cloudypipelines.nexusweb.controller;

import edu.emory.cloudypipelines.nexusweb.db.entity.AppConfig;
import edu.emory.cloudypipelines.nexusweb.db.entity.TaskFile;
import edu.emory.cloudypipelines.nexusweb.db.repo.AppConfigRepo;
import edu.emory.cloudypipelines.nexusweb.db.repo.TaskFileRepo;
import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import io.swagger.annotations.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/admin")
@Api(tags = "API > Admin")
public class SettingController {
    private static final Logger LOGGER = LoggerFactory.getLogger(SettingController.class);
    public final String submissionRootDir = "/tmp/nexus-web/fileupload";
    @Autowired
    AppConfigRepo appConfigRepo;

    @Autowired
    TaskFileRepo taskFileRepo;

    @Value("${ADMIN_EDITOR}")
    private String ADMIN_EDITOR;

    @GetMapping("/appconfig")
    @ApiOperation(value = "List Application Configurations ")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)})
    public ResponseEntity<?> getTaskAppConfigList(@RequestParam(value = "editor", required = true) String editor) {

        final String methodName = "getTaskAppConfigList():";
        if (!validEditor(editor)) {
            LOGGER.error("{} {} is not authorized to perform the operation!", methodName, editor);
            return ControllerUtil.unAuthorized("Unauthorized");
        }
        Iterable<AppConfig> appConfigs = appConfigRepo.findAll();
        return ControllerUtil.OK(appConfigs);
    }

    @PostMapping("/appconfig")
    @ApiOperation(value = "Add or update an application configuration by name/value")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)})
    public ResponseEntity<?> addOrUpdateAppConfig(@ApiParam(name = "name", value = "name", required = true) @RequestParam(value = "name") String name,
                                                  @ApiParam(name = "value", value = "value", required = true) @RequestParam(value = "value") String value,
                                                  @ApiParam(name = "note", value = "note", required = true) @RequestParam(value = "note") String note,
                                                  @ApiParam(name = "editor", value = "editor", required = true) @RequestParam(value = "editor") String editor) {

        final String methodName = "addOrUpdateAppConfig():";
        if (!validEditor(editor)) {
            LOGGER.error("{} {} is not authorized to perform the operation!", methodName, editor);
            return ControllerUtil.unAuthorized("Unauthorized");
        }
        if (CommonUtil.isNullOrEmpty(name) || CommonUtil.isNullOrEmpty(value) || CommonUtil.isNullOrEmpty(note)) {
            LOGGER.error("{} name, value or note is missing", methodName);
            return ControllerUtil.badRequest("key, value or note is required");
        }
        LOGGER.info("{} received name={}, value={}, note={}", methodName, name, value, note);
        AppConfig appConfig = appConfigRepo.findDistinctByName(name.trim());
        if (appConfig == null) {
            appConfig = new AppConfig();
        }
        appConfig.setName(name.trim());
        appConfig.setValue(value.trim());
        appConfig.setNote(note.trim());
        appConfigRepo.save(appConfig);
        return ControllerUtil.OK("Ok");
    }

    @GetMapping("/files")
    @ApiOperation(value = "List files ")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)})
    public ResponseEntity<?> getTaskFileList(@RequestParam(value = "editor", required = true) String editor) {

        final String methodName = "getTaskFileList():";
        if (!validEditor(editor)) {
            LOGGER.error("{} {} is not authorized to perform the operation!", methodName, editor);
            return ControllerUtil.unAuthorized("Unauthorized");
        }
        Iterable<TaskFile> taskFiles = taskFileRepo.findAll();
        return ControllerUtil.OK(taskFiles);
    }

    @PostMapping("/files")
    @ApiOperation(value = "Add or update a file")
    @ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = String.class),
            @ApiResponse(code = 400, message = "Bad request", response = String.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = String.class)})
    public ResponseEntity<?> addOrUpdateFile(@ApiParam(name = "file", value = "file", required = true) @RequestParam(value = "file") MultipartFile file,
                                             @ApiParam(name = "fileName", value = "fileName", required = true) @RequestParam(value = "fileName") String fileName,
                                             @ApiParam(name = "fileType", value = "fileType", required = true) @RequestParam(value = "fileType") String fileType,
                                             @ApiParam(name = "editor", value = "editor", required = true) @RequestParam(value = "editor") String editor) {

        final String methodName = "addOrUpdateFile():";
        if (!validEditor(editor)) {
            LOGGER.error("{} {} is not authorized to perform the operation!", methodName, editor);
            return ControllerUtil.unAuthorized("Unauthorized");
        }
        if (CommonUtil.isNullOrEmpty(fileName) || CommonUtil.isNullOrEmpty(fileType)) {
            LOGGER.error("{} name or type is missing", methodName);
            return ControllerUtil.badRequest("name or type is required");
        }

        LOGGER.info("{} received file={}, name={}, type={}", methodName, file.getOriginalFilename(), fileName, fileType);
        String filePath = saveUploadedFiles(file);
        LOGGER.info("{} saved filePath={}", methodName, filePath);
        String text = CommonUtil.readFile2Text(filePath);
        if (CommonUtil.isNullOrEmpty(text)) {
            LOGGER.error("{} file is empty", methodName);
            return ControllerUtil.badRequest("file is empty");
        }
        TaskFile taskFile = taskFileRepo.findDistinctByFileName(fileName.trim());
        if (taskFile == null) {
            taskFile = new TaskFile();
        }
        taskFile.setFileName(fileName.trim());
        taskFile.setFileType(fileType.trim());
        taskFile.setFileContent(text.trim());
        taskFileRepo.save(taskFile);
        return ControllerUtil.OK("OK");
    }

    private String saveUploadedFiles(MultipartFile multipartFile) {
        String loadDir = CommonUtil.makeDestDirWithTimestamp(submissionRootDir + "/upload");
        return CommonUtil.saveUploadedFile(multipartFile, loadDir);
    }

    private boolean validEditor(String editor) {
        final String methodName = "validEditor():";
        if (CommonUtil.isNullOrEmpty(editor)) {
            LOGGER.error("{} editor is empty, unauthorized!", methodName, editor);
            return false;
        }
        if (editor.startsWith("x") || !editor.equalsIgnoreCase(ADMIN_EDITOR.trim())) {
            LOGGER.error("{} {} is not authorized to perform the operation!", methodName, editor);
            return false;
        }
        return true;
    }
}
