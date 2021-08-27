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
@Table(name = "task_header")
public class TaskHeader {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "task_header_id")
    private String taskHeaderId = "";

    @Column(name = "yaml_config")
    private String yamlConfig = "";

    @Column(name = "json_config")
    private String jsonConfig = "";

    @Column(name = "completed")
    private boolean completed = false;

    @Column(name = "process_status")
    private String processStatus = "";

    @Column(name = "time_submitted")
    private ZonedDateTime timeSubmitted = null;

    @Column(name = "time_completed")
    private ZonedDateTime timeCompleted = null;

    @Column(name = "start_millis")
    private Long startMillis = null;

    @Column(name = "end_millis")
    private Long endMillis = null;
}
