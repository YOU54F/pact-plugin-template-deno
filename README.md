# Pact Deno Plugin Template

A starter template for building a [Pact Plugin](https://github.com/pact-foundation/pact-plugins#plugins) 

- written in TypeScript 
- Utilises [Deno](https://deno.land/)
- Cross compiles to a binary for cross platform execution
- Comes with a CI pipeline, which will publish preview builds on each commit to GitHub Releases
- Will publish `major|minor|patch` releases via a workflow dispatch action on `main` branch

Can be installed via the [pact-plugin-cli](https://github.com/pact-foundation/pact-plugins/tree/main/cli)

```sh
pact-plugin-cli install -y https://github.com/YOU54F/pact-deno-plugin-template/releases/tag/v-0.0.0
```

Use it in your Pact tests with the `deno-template` plugin name.