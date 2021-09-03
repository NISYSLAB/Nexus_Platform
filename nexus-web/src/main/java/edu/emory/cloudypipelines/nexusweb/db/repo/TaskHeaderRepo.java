package edu.emory.cloudypipelines.nexusweb.db.repo;

import edu.emory.cloudypipelines.nexusweb.db.entity.TaskHeader;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TaskHeaderRepo extends CrudRepository<TaskHeader, String> {
    TaskHeader findDistinctByTaskHeaderId(UUID taskHeaderId);
    List<TaskHeader> findDistinctByCompleted(Boolean completed);
}
