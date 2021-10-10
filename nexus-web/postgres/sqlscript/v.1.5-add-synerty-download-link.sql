
-- file engine url on different projects
INSERT INTO app_config (id, name, value, note) VALUES
  (nextval('app_config_id_seq'),'synergy1-file-download-url', 'https://cloudypipeline.bmi.emory.edu/docs/api/download/workflows/CROMWELL_ID/requests/REQUEST_ID/', 'file download url on synergy1'),
  (nextval('app_config_id_seq'),'synergy2-file-download-url', 'https://cloudypipeline.bmi.emory.edu/docs/api/download/workflows/CROMWELL_ID/requests/REQUEST_ID/', 'file download url on synergy2');

-- 

select * from app_config;
