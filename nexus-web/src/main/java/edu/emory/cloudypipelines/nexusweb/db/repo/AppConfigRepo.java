package edu.emory.cloudypipelines.nexusweb.db.repo;

import edu.emory.cloudypipelines.nexusweb.db.entity.AppConfig;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface AppConfigRepo extends CrudRepository<AppConfig, Long> {
    AppConfig findDistinctById(Long id);
    AppConfig findDistinctByName(String name);
}
