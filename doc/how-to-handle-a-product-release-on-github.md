# How to Manage Releases on Github/NPM

## Scope

The scripts and description assumes that you already have setup a release-management pipeline with e.g. [Travis](https://travis-ci.com/), [Github](https://github.com/) and [Semantic-Release](https://github.com/semantic-release/semantic-release). The default semantic-release branch is `master`.

## Examples

![visualizing a standard release on github](./how-to-handle-a-product-release-on-github.jpg)


## Example 1: Unplanned Maintenance

Let's say you are at version `v1.3.0` of your package and a customer needs a bugfix in an old version `v1.0.1`. The execution of `npx release-tools create-release-branch --base-tag=v1.0.1 --release-branch-name=release-2017-10 --npm-token=<token>` creates a new branch `release-2017-10`. From now on you can just add patch commits to `release-2017-10`. `semantic-release` will handle the versioning automatically and counts up step by step `v1.0.2`, `v1.0.3` and so on. `master` just works like expected and counts up from `v1.3.0` if you merge a pull request.

## Example 2: Planned Maintenance

When you have a release cycle (e.g. 1 month), you maybe have to provide a stable package for customers every month. Your latest version on master is `v1.3.0` at the end of the sprint and you want to prepare a release branch with fixes for customers.

1. The versioning of `master` and the release branch shouldn't overlap. therefore, you have to bump the minor version of the master branch before creating the release branch. Execute `git commit --allow-empty -m "feat: bump minor version for release management"`, create and merge a PR to `master`. `semantic-release` will create version `v1.4.0` and therefore the release-branch wont overlap for `1.3.x`
2. Execute `npx release-tools create-release-branch --base-tag=v1.3.0 --release-branch-name=release-2017-12 --npm-token=<token>` - As in example one, this script creates a new branch `release-2017-12`, where you can make patches for `v1.3.x` and you won't have a conflict with `v1.4.0` and newer versions.
