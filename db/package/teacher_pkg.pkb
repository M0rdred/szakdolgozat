CREATE OR REPLACE PACKAGE BODY teacher_pkg AS
  PROCEDURE save_new_subject_for_teacher(p_teacher_id IN NUMBER
                                        ,p_subject_id IN NUMBER) IS
    v_count NUMBER;
  BEGIN
  
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM teached_subject ts
       WHERE ts.teacher_id = p_teacher_id
         AND ts.subject_id = p_subject_id;
    
    EXCEPTION
      WHEN no_data_found THEN
        v_count := 0;
    END;
  
    IF v_count = 1
    THEN
      UPDATE teached_subject ts SET ts.active = 1;
    ELSE
      INSERT INTO teached_subject
        (subject_id
        ,teacher_id
        ,active)
      VALUES
        (p_subject_id
        ,p_teacher_id
        ,1);
    END IF;
  END save_new_subject_for_teacher;

  PROCEDURE delete_subject_from_teacher(p_teacher_id IN NUMBER
                                       ,p_subject_id IN NUMBER) IS
  BEGIN
    UPDATE teached_subject ts
       SET ts.active = 0
     WHERE ts.teacher_id = p_teacher_id
       AND ts.subject_id = p_subject_id;
  END delete_subject_from_teacher;

  PROCEDURE become_teacher(p_user_id IN NUMBER) IS
  BEGIN
    UPDATE person p SET p.role = 'teacher' WHERE p.id = p_user_id;
  END become_teacher;

  PROCEDURE end_teaching(p_teacher_id IN NUMBER) IS
  BEGIN
    UPDATE person p
       SET p.role       = 'user'
          ,p.is_teacher = 0
     WHERE p.id = p_teacher_id;
  END end_teaching;

  PROCEDURE get_subjects_of_teacher(p_teacher_id   IN NUMBER
                                   ,p_subject_list OUT SYS_REFCURSOR) IS
    v_subject_list ty_subject_table;
  BEGIN
    SELECT ty_subject(id          => s.id,
                      NAME        => s.name,
                      description => s.description,
                      active      => s.active,
                      mod_user    => s.mod_user,
                      created_on  => s.created_on,
                      last_mod    => s.last_mod,
                      dml_flag    => s.dml_flag,
                      version     => s.version)
      BULK COLLECT
      INTO v_subject_list
      FROM teached_subject t
      JOIN subject s
        ON s.id = t.subject_id
     WHERE t.teacher_id = p_teacher_id
       AND t.active = 1
       AND t.dml_flag <> 'D';
  
    OPEN p_subject_list FOR
      SELECT * FROM TABLE(CAST(v_subject_list AS ty_subject_table));
  END get_subjects_of_teacher;

END teacher_pkg;
/
