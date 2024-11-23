
<img src="assets/spear.png" width="200">

# ghspear

> Interactively grab/view any file, from any branch, from any repo (you can access..)
> on GitHub.

Useful for grabbing random files from your own repos or others into the current 
directory or to open in your web browser for reference. 

In the following example, we `ghspear` two repositories. 

1. We grab the`README.md` file from `ziglang/zig` master branch.
2. We grab`DockerFile` and `build.sh` from `docker/getting-started` master branch
using **tab to select multiple files**.

<img src="assets/demo.gif">

## Examples

### Personal repos

To grab a file from any branch of any of your repos, just run

```terminal
ghspear
```
You are prompted to interactively choose the repo, branch, then file. 

### Other user repos 

Say you wanted to grab a file from the user `ziglang`, use the `-o` (owner) flag:

```terminal
ghspear -o ziglang
```

You can specify a repo (and branch) if you already know it (skips fuzzy selection) using
a `/` to separate in the `<owner>/<repo>/<branch>` pattern. e.g.:

```terminal
ghspear -o ziglang/zig
```

### View on web instead of download file
To open to the file in GitHub via your browser, use the `-w` flag:

```terminal
ghspear -w -o ziglang
```

> [!NOTE]
> When grabbing single files, remember to still respect the licence of the repo.

## Requirements
- [`gh`](https://cli.github.com/)
- [`fzf`](https://github.com/junegunn/fzf)
- [`jq`](https://jqlang.github.io/jq/) (often already installed.)

Assumes you have already setup GitHub's CLI `gh`.

## Setup

1. Make ghspear.sh executable

```terminal
chmod +x path/to/ghspear.sh
```
Replace with your actual path.

2. In your `.bashrc` / `.zshrc` etc. add an alias to the script. 
e.g.

```shell
alias ghspear="~/code/ghspear/ghspear.sh"
```
Replace with your actual path.
