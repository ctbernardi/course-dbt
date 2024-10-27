{% macro aggregate_distinct_counts(table_name, filter_column, count_column) %}
  {% set distinct_values = dbt_utils.get_column_values(
    table=ref(table_name), 
    column=filter_column
  ) %}

  {% for value in distinct_values %}
    count(distinct case when {{ filter_column }} = '{{ value }}' then {{ count_column }} else null end) as {{ value }}s
    {% if not loop.last %},{% endif %}
  {% endfor %}
{% endmacro %}

