# Contributing

KubeFleet website repository welcomes contributions and feedbacks! Help us make KubeFleet documentation better, improve the website experience, and translate documents into different languages for developer around the globe.

## Terms

All contributions to the repository must be submitted under the terms of the [CC BY 4.0 International](https://creativecommons.org/licenses/by/4.0/deed.en) license.

## Certificate of Origin

By contributing to this project, you agree to the Developer Certificate of Origin (DCO). This document was created by the Linux Kernel community and is a simple statement that you, as a contributor, have the legal right to make the contribution. See the [DCO](DCO) file for details.

### DCO Sign Off

You must sign off your commit to state that you certify the [DCO](DCO). To certify your commit for DCO, add a line like the following at the end of your commit message:

```
Signed-off-by: John Smith <john@example.com>
```

This can be done with the `--signoff` option to `git commit`. See the [Git documentation](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt--s) for details.

## Code of Conduct

The KubeFleet project has adopted the CNCF Code of Conduct. Refer to our [Community Code of Conduct](CODE_OF_CONDUCT.md) for details.

## Adding to the KubeFleet documentation

The KubeFleet documentation is checked into the `/content` directory. Each language has its own version of documentation: for example, the English version of the documentation is available at `/content/en`. The system uses the [ISO 639](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) and optionally the [ISO 3166](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) country codes to uniquely identify a language version.

The English version of the documentation shall be the source of truth for all other language versions. If you plan to document a new KubeFleet feature or a behavior change, update the English version first. When editing documentation in langauges other than English, make sure that the edited documents are consistent with their English counterparts.

> **Adding a new language version**
>
> The KubeFleet project pledges our best efforts to make sure that the documentation is accessible to all developers around the globe, regardless of their preferred languages. However, due to various limitations, at this moment we have only set up two language versions, `en` for English and `zh-ch` for Simplified Chinese, in the repository. If you have a strong interest to read the KubeFleet documentation in another language, raise a [GitHub issue](https://github.com/kubefleet-dev/website/issues); we will evaluate the possibility and, if conditions allow, set up the version for you.

Each language version of the KubeFleet documentation consists of the following parts:

* A homepage (e.g., `/content/en/_index.md`);
* An documentation opening page (e.g., `/content/en/docs/_index.md`), which explains about KubeFleet and how to use the documentation;
* The concepts (e.g., `/content/en/docs/concepts/`): a collection of documents each of which explains about a specific concept in KubeFleet;
* The getting started tutorials (e.g., `/content/en/docs/getting-started`): a collection of tutorials each of which help developers to get familiar with KubeFleet with a specific setup;
* the how-to guides (e.g., `/content/en/docs/how-tos`): a collection of guides each of which explains about how to use a specific KubeFleet feature;
* the FAQ (e.g., `/content/en/docs/faq`), which answers some of the most common questions developers might have with KubeFleet;
* the KubeFleet API references (e.g., `/content/en/docs/api-reference`).

All the documents includes are written in [the Markdown language](https://en.wikipedia.org/wiki/Markdown). Both the basic syntax and the extended syntax are supported. To edit the documentation, simply find the Markdown file of interest, make some changes, and submit them as a PR.

> The KubeFleet API references are auto-generated. Do not edit it manually.

If you would like to add a new document to one of the collections (concepts, getting started tutorials, or how-to guides), create a Markdown file in the corresponding subdirectory, and submit it in a PR. The Markdown file should start with a header as follows:

```
---
title: YOUR-TITLE
description: YOUR-DOCUMENT-DESCRIPTION
weight: YOUR-PAGE-WEIGHT
---
```

Replace `YOUR-TITLE` and `YOUR-DOCUMENT-DESCRIPTION` with values of your own respectively; these values will be used when rendering the Markdown file into a webpage. Assign a proper numeric value to `YOUR-PAGE-WEIGHT`, which determines the order of your document in the table of contents: for example, the document with the least weight in the concepts collection of documents would appear at the top of the TOC for the concepts section.

## Building and Deploying the Website

The KubeFleet repository has set up a GitHub Actions pipeline to build the website and deploy it to [GitHub Pages](https://kubefleet.dev) every time a PR is merged into the `main` branch. Track the build + deployment status in the [GitHub Workflow page](https://github.com/kubefleet-dev/website/actions/workflows/github-pages.yml); once deployed, your changes should appear on the [GitHub Pages](https://kubefleet.dev) right away.

The same pipeline would also run on each PR; the workflow would attempt to build the website, but no deployment is performed. Use this check to verify if your changes are valid.

### Building and Deploying the Website Locally

Often contributors would need to build and deploy the website locally to check their progress. To do so,

* Install [Hugo](https://gohugo.io).
    * Hugo is the static site generator KubeFleet uses to generate the website. It is recommended that you install the extended version.
* Install a [Node.js runtime](https://nodejs.org/).
    * It is recommended that you install a Node.js LTS version no earlier than Node.js v18.
* Clone the `kubefleet-dev/website` repository.
* Clone all the submodules in the `kubefleet-dev/website` repository:

    ```sh
    git submodule update --init
    git pull --recurse-submodules
    ```

    KubeFleet features the following submodules:
    * the `docsy` Hugo theme;
    * the FontAwesome lib;
    * Bootstrap CSS
    
    These submodules are some of the fundamental building blocks used for generating the KubeFleet website.

* Install the dependencies Hugo uses to build the website with the command `npm install`.
* Run the Hugo built-in web server:

    ```sh
    hugo server
    ```

    By default Hugo will serve the website at `localhost:1313/website`. Hugo supports hot reload; in most cases you should be able to edit Markdown files and see the website gets rebuilt live.
