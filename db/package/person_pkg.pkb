-- person_pkg body
CREATE OR REPLACE PACKAGE BODY person_pkg AS
  PROCEDURE new_person(p_first_name      VARCHAR2
                      ,p_last_name       VARCHAR2
                      ,p_birth_date      DATE
                      ,p_ad_country      VARCHAR2
                      ,p_ad_city         VARCHAR2
                      ,p_ad_street       VARCHAR2
                      ,p_ad_house_number VARCHAR2
                      ,p_introduction    VARCHAR2) IS
    l_count NUMBER;
  BEGIN
    IF p_first_name IS NOT NULL
       AND p_last_name IS NOT NULL
       AND p_birth_date IS NOT NULL
       AND p_ad_country IS NOT NULL
       AND p_ad_city IS NOT NULL
       AND p_ad_street IS NOT NULL
       AND p_ad_house_number IS NOT NULL
    THEN
    
      SELECT COUNT(*)
        INTO l_count
        FROM person p
       WHERE p.first_name = p_first_name
         AND p.last_name = p_last_name
         AND p.birth_date = p_birth_date;
    
      IF l_count > 0
      THEN
        raise_application_error(-20001,
                                'The given person is already existing in the database');
      ELSE
      
        INSERT INTO person
          (first_name
          ,last_name
          ,birth_date
          ,address_id
          ,introduction)
        VALUES
          (p_first_name
          ,p_last_name
          ,p_birth_date
          ,address_sq.currval
          ,p_introduction);
      END IF;
    
    ELSE
      raise_application_error(-20001, 'One or more parameters are empty');
    END IF;
  END;

  PROCEDURE modify_person_data(p_id         NUMBER
                              ,p_first_name VARCHAR2
                              ,p_last_name  VARCHAR2
                              ,p_birth_date DATE) IS
  BEGIN
    IF p_id IS NOT NULL
       AND p_first_name IS NOT NULL
       AND p_last_name IS NOT NULL
       AND p_birth_date IS NOT NULL
    THEN
    
      UPDATE person p
         SET p.first_name = p_first_name
            ,p.last_name  = p_last_name
            ,p.birth_date = p_birth_date
       WHERE p.id = p_id;
    ELSE
      raise_application_error(-20001, 'One or more parameters are empty');
    END IF;
  END;

  PROCEDURE modify_introduction(p_id           NUMBER
                               ,p_introduction VARCHAR2) IS
  BEGIN
    IF p_id IS NOT NULL
       AND p_introduction IS NOT NULL
    THEN
      UPDATE person p
         SET p.introduction = p_introduction
       WHERE p.id = p_id;
    ELSE
      raise_application_error(-20001, 'One or more parameters are empty');
    END IF;
  END;

  PROCEDURE modify_address(p_id              NUMBER
                          ,p_ad_country      VARCHAR2
                          ,p_ad_city         VARCHAR2
                          ,p_ad_street       VARCHAR2
                          ,p_ad_house_number VARCHAR2) IS
    l_address_id NUMBER;
  BEGIN
    IF p_id IS NOT NULL
       AND p_ad_country IS NOT NULL
       AND p_ad_city IS NOT NULL
       AND p_ad_street IS NOT NULL
       AND p_ad_house_number IS NOT NULL
    THEN
    
      SELECT p.address_id
        INTO l_address_id
        FROM person p
       WHERE p.id = p_id;
    
      UPDATE address a
         SET a.country      = p_ad_country
            ,a.city         = p_ad_city
            ,a.street       = p_ad_street
            ,a.house_number = p_ad_house_number
       WHERE a.id = l_address_id;
    
    ELSE
      raise_application_error(-20001, 'One or more parameters are empty');
    END IF;
  END;

END person_pkg;
/
