# SpiderHub
SpiderHub is a crawler package management repository for the TSDAP platform, designed to support various data sources and simplify data acquisition tasks. All crawler modules conform to standard interface specifications, facilitating integration and automated publishing.

[中文文档](README_zh.md)

## Objectives
SpiderHub aims to provide developers and users with a standardized crawler module management platform that ensures high-quality, maintainable crawler code with automated publishing for ease of use.

## Contribution Process
1. Developers submit an issue with the crawler idea, including data sources, goals, and implementation details. After review by Core Dev, proceed to the development stage.
2. Ensure that the latest version of the interface files (`interface` folder) is downloaded locally, and develop the crawler according to the interface specifications.
3. Once the crawler development is complete, submit a PR for review by Core Dev. There may be feedback during the review process that requires developer modifications.
4. Approved crawlers are automatically packaged into a zip file by GitHub Actions and published to the Release page.

## Notes
- All code must conform to the PEP8 standard; otherwise, it will not be accepted.
- Before submitting each PR, ensure that the interface file is the latest version.
- Only submit necessary files related to the crawler, and exclude unrelated files (such as interface files, IDE caches, etc.).
