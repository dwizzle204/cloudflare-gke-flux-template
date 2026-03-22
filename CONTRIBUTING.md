# Contributing

This repository is published as a learning template, not as a collaborative upstream project.

## What is welcome

- Issues that report bugs or unclear documentation
- Issues that suggest improvements to the template
- Forks and template-generated copies for your own experiments and deployments

## What is not accepted

- Pull requests against this upstream repository

If you want to change or extend the template for your own use, create your own copy from the template repository or fork it and work there.

## Why

This repository is intentionally kept in a partially configured, reusable state.
Most live workflows only make sense after a user configures their own Cloudflare, GCP, GitHub, and secret values in a copy of the template.

## How to use this repository

1. Create a new repository from the template.
2. Replace the placeholders in `gitops/`.
3. Configure secrets and authentication in your own repository.
4. Run the workflows from your configured copy.

For the step-by-step flow, start with `README.md` and `docs/index.md`.
