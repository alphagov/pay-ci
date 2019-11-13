# pay-omnibus

Pay on PaaS.

## Contents

- `ci`: Concourse pipelines and tasks
- `docs`: Technical documentation using the [tech-docs-gem](https://github.com/alphagov/tech-docs-gem/)
- `local`: Stuff for local testing and development
- `paas`: Cloud Foundry manifests for Pay services
- `secrets`: Secrets store using [pass](https://passwordstore.org)

## Documentation

More information can be found in the technical documentation.
You can read the documentation by entering the `docs` directory and running:

```sh
bundle install
bundle exec middleman server
```

The docs are also published online at <https://pay-omnibus-docs.london.cloudapps.digital>.
