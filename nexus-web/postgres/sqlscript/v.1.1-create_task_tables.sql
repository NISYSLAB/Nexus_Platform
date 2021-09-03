-- table task_header
CREATE TABLE task_header (
   task_header_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
   yaml_config TEXT DEFAULT '',
   input_path VARCHAR(500) DEFAULT '',
   json_config TEXT DEFAULT '',
   label VARCHAR(250),
   completed BOOLEAN NOT NULL DEFAULT FALSE,
   process_status VARCHAR(100) DEFAULT '',
   time_submitted TIMESTAMP WITH TIME ZONE,
   time_completed TIMESTAMP WITH TIME ZONE,
   start_millis bigint default 0,
   end_millis bigint
);

CREATE TABLE task (
    task_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_header_id UUID REFERENCES task_header (task_header_id),
    task_index SMALLINT,
    task_name VARCHAR(200),
    cromwell_id VARCHAR(100),
    request_id VARCHAR(100),
    wf_wdl_file TEXT DEFAULT '',
    wf_input_file TEXT DEFAULT '',
    wf_option_file TEXT DEFAULT '',
    wf_type VARCHAR(100),
    process_status VARCHAR(100) DEFAULT '',
    project VARCHAR(500),
    email VARCHAR(500),
    label VARCHAR(500),
    running_hours_allowed SMALLINT DEFAULT 24,
    preemptible_option VARCHAR(200),
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    result_output VARCHAR(1000),
    note TEXT,
    time_submitted TIMESTAMP WITH TIME ZONE,
    time_completed TIMESTAMP WITH TIME ZONE,
    start_millis bigint default 0,
    end_millis bigint
  );

