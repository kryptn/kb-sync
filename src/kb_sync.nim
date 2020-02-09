import os
import httpclient
import strformat
import json


type
    Config = object
        githubToken: string
        repo: string
        owner: string
        workflowName: string

        workDir: string

    Artifact = object
        nodeId: string
        content: string


proc githubClient(config: Config): HttpClient =
    result = newHttpClient()
    result.headers = newHttpHeaders({"Authorization": fmt"bearer {config.githubToken}"})


proc getWorkflowRunsUrl(config: Config): string =
    fmt"https://api.github.com/repos/{config.owner}/{config.repo}/actions/workflows/{config.workflowName}/runs"


proc pullEnvs(): Config = 
    return Config(
        githubToken: $getEnv("GITHUB_TOKEN"), 
        repo: $getEnv("REPO"),
        owner: $getEnv("OWNER"),
        workflowName: $getEnv("WORKFLOW_NAME"),
        workDir: $getEnv("WORK_DIR", "/tmp")
    )


proc getLatestRun(client: HttpClient, config: Config): JsonNode =
    # https://developer.github.com/v3/actions/workflow_runs/
    let workflowRunsNode = client.getContent(config.getWorkflowRunsUrl).parseJson
    return workFlowRunsNode["workflow_runs"].getElems()[0]

proc getLatestArtifact(client: HttpClient, run: JsonNode): JsonNode =
    # https://developer.github.com/v3/actions/artifacts/
    let artifactsNode = client.getContent(run["artifacts_url"].getStr()).parseJson
    return artifactsNode["artifacts"].getElems()[0]


proc downloadArtifact(config: Config): Artifact =
    let client = config.githubClient()

    let latestRun = client.getLatestRun(config)
    let latestArtifact = client.getLatestArtifact(latestRun)

    let artifactArchiveUrl = latestArtifact["archive_download_url"].getStr()
    
    return Artifact(
        nodeId: latestArtifact["node_id"].getStr(),
        content: client.getContent(artifactArchiveUrl)
    )

proc extractFirmware(artifact: Artifact, config: Config): string =

    let workDir = fmt"{config.workDir}/fm_sync.{artifact.nodeId}"
    discard existsOrCreateDir(workDir)

    let zipFilename = fmt"{workDir}/firmware.zip"

    # write zipfile to temp & extract
    writeFile(zipFilename, artifact.content)
    discard execShellCmd(fmt"unzip -o {zipFileName} -d {workDir}")

    let binWalkPattern = fmt"{workDir}/*.bin"

    # return first bin file
    for bin in walkFiles(binWalkPattern):
        return bin

  
proc getFirmware(config: Config): string = 

    let artifact = downloadArtifact(config)
    let firmwareBinFilename = extractFirmware(artifact, config)

    return firmwareBinFilename

when isMainModule:
    let config = pullEnvs()

    let firmwareBinFilename = getFirmware(config)
    discard execShellCmd(fmt"wally-cli {firmwareBinFilename}")
