set serveroutput on;

declare
  pi constant real := 3.14159265359;
  circumference real;
  area real;
  -- prompted for radius
  radius real := &radius;
begin
  circumference := pi * radius * 2.0;
  area := pi * radius**2;
  dbms_output.put_line('Radius = ' || TO_CHAR(radius) ||
                       ',Circum = ' || TO_CHAR(circumference) ||
                       ', Area = ' || TO_CHAR(area);
end;
