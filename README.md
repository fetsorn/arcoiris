# Arcoíris

Redistribute wealth according to arbitrary algorithm. Inspired by the [Rainbow gathering](https://es.wikipedia.org/wiki/Encuentros_Arco%C3%ADris).

## Documentation 📚

Smart contract documentation is [here](https://github.com/fetsorn/arcoiris/blob/main/docs/src/SUMMARY.md).

## Developer Information and Tools 👩‍💻

### Install dependencies 👷‍♂️

> **Note**
> If you use [nix](https://nixos.org/), run `nix develop` to install all dependencies in PATH

You'll need to install nodejs >= 18.15.0. We use yarn but npm should work too. You'll also need to install [foundry](https://book.getfoundry.sh/getting-started/installation#using-foundryup) and [solc](https://github.com/crytic/solc-select). Assuming that's done, run `yarn` with no args:

```
yarn
```

### Build the code 🧐

To compile the contracts:

```
yarn compile
```

### Run tests 🦾

To run both foundry and hardhat tests:

```
yarn test
```

### Running the linter 🧽

To run the linter in the default mode, where it will print all errors and not modify code, run:

```
yarn lint
```

### Coverage 🔎

We use the [solidity-coverage](https://github.com/sc-forks/solidity-coverage) package to generate coverage reports for hardhat in `coverage/` and [forge coverage](https://book.getfoundry.sh/reference/forge/forge-coverage) for foundry tests in `coverage-foundry`.
You can generate the coverage reports locally by running:

```
yarn coverage
yarn hardhat coverage
```

The full reports can be viewed by opening the `coverage/index.html` and `coverage-foundry/index.html` files in a browser.

### Deploy and interact 🚀

Enter your private key to the `.env` file from `.env.example` template. Double-check the deploy script and run:

```
yarn hardhat run scripts/deploy.js
```

You can deploy to your network of choice by modifying `hardhat.config.ts` and adding the flag `--network yourNetwork` to the invocation.

```
    yourNetwork: {
      url: "https://example.com",
      accounts: [PRIVATE_KEY],
    },

```

### Verify 📄

To verify the source code with a network explorer, it's best to generate json metadata.

```
yarn hardhat solidity-json
```

Choose `Standard-Json-Input` in the explorer verification dialog and upload json from `artifacts/solidity-json/contracts/`.
