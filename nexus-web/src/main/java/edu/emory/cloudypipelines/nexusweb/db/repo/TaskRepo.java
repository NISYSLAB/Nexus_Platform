package edu.emory.cloudypipelines.nexusweb.db.repo;

import edu.emory.cloudypipelines.nexusweb.db.entity.Task;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.UUID;

public interface TaskRepo extends CrudRepository<Task, String> {
    List<Task> findDistinctByCompletedAndProcessStatus(boolean completed, String processStatus);
    List<Task> findDistinctByTaskHeaderIdAndTaskIndexGreaterThan(UUID taskHeaderId, int taskIndex);
    List<Task> findDistinctByTaskHeaderIdAndTaskIndex(UUID taskHeaderId, int taskIndex);
}
