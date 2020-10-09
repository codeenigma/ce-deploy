# Admin credentials

Reset the admin username and/or password on each build.

<!--ROLEVARS-->
## Default variables
```yaml
---
admin_creds:
  username: "{{ lookup('password', '/dev/null chars=ascii_letters length=20') }}"
  password: "{{ lookup('password', '/dev/null length=40') }}"

```

<!--ENDROLEVARS-->
