-- tests/test_5_digits.sql
{% test five_digits(model, column_name) %}
  SELECT *
  FROM {{ model }}
  WHERE LENGTH({{ column_name }}) != 5
    OR {{ column_name }} NOT RLIKE '^[0-9]{5}$'
{% endtest %}
