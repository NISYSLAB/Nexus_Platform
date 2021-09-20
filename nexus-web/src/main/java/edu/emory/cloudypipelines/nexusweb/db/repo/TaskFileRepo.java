package edu.emory.cloudypipelines.nexusweb.db.repo;

import edu.emory.cloudypipelines.nexusweb.db.entity.TaskFile;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TaskFileRepo extends CrudRepository<TaskFile, String> {
    TaskFile findDistinctByFileName(String fileName);
}
