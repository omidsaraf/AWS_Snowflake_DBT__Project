{% macro mask_account(column_name) %}
    -- Shows only the last 4 digits: ****-****-1234
    CONCAT('****-****-', RIGHT({{ column_name }}, 4))
{% endmacro %}
