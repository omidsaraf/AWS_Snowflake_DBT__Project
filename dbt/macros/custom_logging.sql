-- {% macro log_model_results(results) %}
    
--     {% if execute %}
--         {% for res in results %}
--             {% set line -%}
--                 insert into {{ target.database }}.{{ target.schema }}.dbt_audit_log (
--                     model_name,
--                     status,
--                     rows_affected,
--                     execution_time_seconds,
--                     run_started_at
--                 ) values (
--                     '{{ res.node.name }}',
--                     '{{ res.status }}',
--                     {{ res.adapter_response.get('rows_affected', 0) }},
--                     {{ res.execution_time }},
--                     current_timestamp
--                 );
--             {%- endset %}
            
--             {% do run_query(line) %}
--         {% endfor %}
--     {% endif %}

-- {% endmacro %}


{% macro log_model_results(results) %}
    
    {% if execute %}
        {% for res in results %}
            {% set line -%}
                insert into {{ target.database }}.{{ target.schema }}.dbt_audit_log (
                    model_name,
                    status,
                    rows_affected,
                    execution_time_seconds,
                    run_started_at
                ) values (
                    {# Use double quotes for the Jinja filter to avoid clashing with single quotes #}
                    "{{ res.node.name | replace("'", "''") }}", 
                    '{{ res.status }}',
                    {# Using a simple inline if/else is often cleaner for the IDE than the list max filter #}
                    {{ res.adapter_response.get('rows_affected', 0) if res.adapter_response.get('rows_affected', 0) > 0 else 0 }},
                    {{ res.execution_time }},
                    current_timestamp
                );
            {%- endset %}
            
            {% do run_query(line) %}
        {% endfor %}
    {% endif %}

{% endmacro %}
