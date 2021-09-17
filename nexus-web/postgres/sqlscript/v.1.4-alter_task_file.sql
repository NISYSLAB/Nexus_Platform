
drop table task_file;

-- table task_header
CREATE TABLE task_file (
   file_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
   file_name CITEXT NOT NULL UNIQUE,
   file_type VARCHAR(100) DEFAULT '',
   file_content TEXT DEFAULT '',
   time_created TIMESTAMP WITH TIME ZONE
);
