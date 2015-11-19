{% from "mona/macro.jinja" import sls_block %}

monit_installed:
    pkg.installed:
        - name: monit
    service.running:
        - enable: True
        - name: monit
        - watch:
            - file: /etc/monit/monitrc
            - file: /etc/monit/conf.d/*

/etc/monit/monitrc:
    file.managed:
        - source: salt://mona/files/monitrc
        - template: jinja
        - require:
            - pkg: monit_installed

/etc/monit/conf.d:
    file.directory:
        - makedirs: True
        - require:
            - pkg: monit_installed

/etc/monit/conf.d/salt-minion:
  file.managed:
    - source: salt://mona/files/processes/salt-minion
    - template: jinja
    - require:
      - pkg: monit_installed

{% if salt['pillar.get']('mona:processes') is defined %}
{% for item in salt['pillar.get']('mona:processes') %}
/etc/monit/conf.d/{{ item }}:
    file.managed:
        - source: salt://mona/files/processes/{{ item }}
        - template: jinja
        - require:
            - pkg: monit_installed
{% endfor %}
{% endif %}

{% if salt['pillar.get']('mona:apache2_file_check') is defined %}
{{ salt['pillar.get']('mona:apache2_file_check:location', '/var/www/default/httpdocs/monit.html') }}:
  file.managed:
    - source: {{ salt['pillar.get']('mona:apache2_file_check:source', 'salt://roles/rapidpanel/files/monit/monit.html') }}
    {{ sls_block(salt['pillar.get']('mona:apache2_file_check:opts')) }}
{% endif %}