{% if 'wes' in pillar %}
wes:
  user.present: {{ pillar['wes']['user.present'] }}
  ssh_auth.present: {{ pillar['wes']['ssh_auth.present'] }}
{% endif %}
