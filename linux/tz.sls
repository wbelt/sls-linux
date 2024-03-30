{% if 'timezone.system' in pillar %}
tz:
  timezone.system:
    - name: {{ pillar['timezone.system'] }}
{% endif %}
