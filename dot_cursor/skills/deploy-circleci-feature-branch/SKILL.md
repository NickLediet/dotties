---
name: deploy-feature-branch
description: Deploys the associated feature branch for this branch/pr via the CircleCI
---
# Deploy 
Detailed step-by-step guidance and instructions for the agent to follow.

## When to Use
* when the user requests you deploy the associated feature branch

## Instructions
1. query the circle ci cli's available commands by running `circleci --help`
2. Find the related pipeline for this branch/PR
3. Look for a pending "Deploy Feature Branch" job for the associated pipeline and branch
4. Approve the deployment
