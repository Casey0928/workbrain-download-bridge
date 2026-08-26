# WorkBrain Download Bridge

Use a public GitHub Actions runner as an ephemeral download worker: stream an HTTPS file directly to Google Drive without committing the downloaded file, using Actions Artifact, cache, Packages, or Git LFS.

## Architecture

`HTTPS URL -> GitHub Actions (ubuntu-latest) -> rclone rcat -> Google Drive/WorkBrain/Downloads`

## One-time Google Drive credential

The workflow expects an rclone remote named `gdrive` and a repository Actions secret named `RCLONE_CONFIG_B64`.

On your Mac:

```bash
brew install rclone
rclone config
```

Create a Google Drive remote named exactly `gdrive`, then locate its config:

```bash
rclone config file
```

Encode it:

```bash
base64 < ~/.config/rclone/rclone.conf | pbcopy
```

In this repository open **Settings -> Secrets and variables -> Actions -> New repository secret**. Create `RCLONE_CONFIG_B64` and paste the Base64 value.

Do not commit `rclone.conf` to this repository.

## Run

Open **Actions -> Download URL to Google Drive -> Run workflow**.

Suggested first test:

- URL: `https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf`
- Filename: `github-actions-bridge-test.pdf`
- Drive path: `WorkBrain/Downloads`

## Safety and quota design

- manual `workflow_dispatch` only
- HTTPS only
- rejects localhost/private/link-local/reserved destinations
- standard `ubuntu-latest` runner
- no `actions/upload-artifact`
- no `actions/cache`
- no GitHub Packages
- no Git LFS
- file bytes are streamed directly to Google Drive
