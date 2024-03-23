{% if 'timezone.system' in pillar %}
include:
  - sls-linux.tz
{% endif %}

{% if 'wes' in pillar %}
include:
  - sls-linux.addwes
{% endif %}

{% if 'rustserver' in pillar %}
include:
  - sls-linux.rust-install
{% endif %}
