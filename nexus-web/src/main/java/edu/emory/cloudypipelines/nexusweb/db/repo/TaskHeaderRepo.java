package edu.emory.cloudypipelines.nexusweb.db.repo;

import edu.emory.cloudypipelines.nexusweb.db.entity.TaskHeader;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TaskHeaderRepo extends CrudRepository<TaskHeader, String> {
}
