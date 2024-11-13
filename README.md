
<img src="assets/spear.png" width="200">

# ghspear

> Interactively grab/view any file, from any branch, from any repo (you can access..) on GitHub.

A dumb script... but useful!

## Example - Your repos

To grab a file from any branch of any of your repos, just run

```terminal
ghspear
```
You are prompted to interactively chose the repo, branch, then file. 

## Example - Other users 

Say you wanted to grab a file from the user `ziglang`, use the `-o` flag:

```terminal
ghspear -o ziglang
```

You can specify a repo if you already know it (skips picking the repo).

```terminal
ghspear -o ziglang/zig
```

## Example - view on web
To open to the file in GitHub via your browser, use the `-w` flag:

```terminal
ghspear -w -o ziglang
```

## Requirements
- `gh`
- `fzf`

Assumes you have already setup GitHub's CLI `gh`.

## Setup






