-- https://devgym.oracle.com/pls/apex/f?p=10001:11:104276786953387::NO:RP:P11_RESET_RDS,P11_NEW_THREAD,P11_NEW_SUBJECT,P11_COMMENT:N,,,&cs=1WDn_wpn1vPLi7BnUkpEuKu6qlt4ZN4BfRr3ES0llVOash1RUr-RpQuH03jjvACs91NXgF5ydJGXsaC_4t7x2DA
CREATE OR REPLACE PACKAGE contact_pkg
IS
   TYPE phone_num_rt IS RECORD (
      area_code      VARCHAR2 (3)
    , phone_prefix   VARCHAR2 (3)
    , phone_number   VARCHAR2 (10)
   );

   TYPE always_in_contact_rt IS RECORD (
      home_phone       phone_num_rt
    , office_phone     phone_num_rt
    , cell_phone       phone_num_rt
    , fax_phone        phone_num_rt
    , bathroom_phone   phone_num_rt
    , bathroom_fax     phone_num_rt
   );

   PROCEDURE show_bathroom_info(contact_in always_in_contact_rt);
END contact_pkg;
/

CREATE OR REPLACE PACKAGE BODY contact_pkg
IS
   PROCEDURE show_bathroom_info (contact_in always_in_contact_rt)
   IS
   BEGIN
     DBMS_OUTPUT.put_line ('Bathroom Phone:');
     DBMS_OUTPUT.put_line ('Area code ' || contact_in.bathroom_phone.area_code);
     DBMS_OUTPUT.put_line ('Phone prefix ' || contact_in.bathroom_phone.phone_prefix);
     DBMS_OUTPUT.put_line ('Phone number ' || contact_in.bathroom_phone.phone_number);
   END show_bathroom_info;
END contact_pkg;
/

DECLARE
   l_contact   contact_pkg.always_in_contact_rt;
BEGIN
   l_contact.bathroom_phone.area_code := '773';
   l_contact.bathroom_phone.phone_prefix := '426';
   l_contact.bathroom_phone.phone_number := '9093';
   contact_pkg.show_bathroom_info(l_contact);
END;
/

DROP PACKAGE contact_pkg
/
