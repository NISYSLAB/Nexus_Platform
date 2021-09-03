-- Table: app_config

CREATE TABLE app_config (
  id SERIAL PRIMARY KEY,
  name CITEXT NOT NULL UNIQUE,
  value VARCHAR(500),
  note VARCHAR(200)
);

-- sequence
ALTER SEQUENCE public.app_config_id_seq INCREMENT 5;

-- file engine url on different projects
INSERT INTO app_config (id, name, value, note) VALUES
  (nextval('app_config_id_seq'),'cloudypipelines-file-download-url', 'https://pipelineapi.org:9555/api/download/workflows/{cromwellId}/requests/{requestId}', 'file download url on CloudyPipelines'),
  (nextval('app_config_id_seq'),'nexus-bmi-file-download-url', 'https://cloudypipeline.bmi.emory.edu/docs/api/download/workflows/{cromwellId}/requests/{requestId}', 'file download url on CloudyPipelines');

-- 
UPDATE app_config set value = 'https://pipelineapi.org:9555/api/download/workflows/CROMWELL_ID/requests/REQUEST_ID' where name = 'cloudypipelines-file-download-url';
UPDATE app_config set value = 'https://cloudypipeline.bmi.emory.edu/docs/api/download/workflows/CROMWELL_ID/requests/REQUEST_ID' where name = 'nexus-bmi-file-download-url';
