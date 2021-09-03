-- table task_header
CREATE TABLE task_file (
   file_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
   id UUID, -- either task_id or task_header_id
   is_header BOOLEAN NOT NULL DEFAULT FALSE,
   file_type VARCHAR(100) DEFAULT '',
   file_content TEXT DEFAULT '',
   time_created TIMESTAMP WITH TIME ZONE
);