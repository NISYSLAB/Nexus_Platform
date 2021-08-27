package edu.emory.cloudypipelines.nexusweb.db.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;
import java.time.ZonedDateTime;

@Getter
@Setter
@NoArgsConstructor
@ToString
@Entity
@Table(name = "task")
public class Task {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "task_id")
    private String taskId = "";

    @Column(name = "parent_task_id")
    private String parentTaskId = "";

    @Column(name = "task_header_id")
    private String taskHeaderId = "";

    @Column(name = "cromwell_id")
    private Integer cromwellId;

    @Column(name = "request_id")
    private String requestId = "";

    @Column(name = "wf_wdl_file")
    private String wfWdlFile = "";

    @Column(name = "wf_input_file")
    private String wfInputFile = "";

    @Column(name = "wf_option_file")
    private String wfOptionFile = "";

    @Column(name = "wf_type")
    private String wfType = "";

    @Column(name = "process_status")
    private String processStatus = "";

    @Column(name = "project")
    private String project = "";

    @Column(name = "email")
    private String email = "";

    @Column(name = "label")
    private String label = "";

    @Column(name = "preemptible_option")
    private String preemptibleOption = "";

    @Column(name = "running_hours_allowed")
    private int runningHoursAllowed = 24;

    @Column(name = "completed")
    private boolean completed = false;

    @Column(name = "result_output")
    private String resultOutput = "";

    @Column(name = "note")
    private String note = "";

    @Column(name = "time_submitted")
    private ZonedDateTime timeSubmitted = null;

    @Column(name = "time_completed")
    private ZonedDateTime timeCompleted = null;

    @Column(name = "start_millis")
    private Long startMillis = null;

    @Column(name = "end_millis")
    private Long endMillis = null;
}
