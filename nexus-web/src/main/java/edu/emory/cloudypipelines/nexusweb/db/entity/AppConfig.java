package edu.emory.cloudypipelines.nexusweb.db.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;

@Getter
@Setter
@NoArgsConstructor
@ToString
@Entity
@Table(name = "app_config")
public class AppConfig {
    @Id
    @GeneratedValue(generator = "app_config_id_seq", strategy = GenerationType.SEQUENCE)
    @SequenceGenerator(
            name = "app_config_id_seq",
            sequenceName = "app_config_id_seq",
            allocationSize = 5
    )
    private Long id;

    @Column(name = "name")
    private String name = "";

    @Column(name = "value")
    private String value = "";

    @Column(name = "note")
    private String note = "";
}
