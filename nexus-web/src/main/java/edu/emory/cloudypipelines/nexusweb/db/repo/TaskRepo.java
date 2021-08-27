package edu.emory.cloudypipelines.nexusweb.db.repo;

import edu.emory.cloudypipelines.nexusweb.db.entity.Task;
import org.springframework.data.repository.CrudRepository;

public interface TaskRepo extends CrudRepository<Task, String> {
}
