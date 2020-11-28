@Library('PipelineUtilities')
@Library('scloud-pipeline-libraries@refactor')

// Flags
Boolean isTested = false
Boolean deployed = false
String jenkinsStage
String[] archiveGlobs = [
    "node/**",
    "node_modules/**",
    "serverless.yml",
    "serverless/**",
    "build/distributions/console-login.zip",
    ".env.development-full"

]
String projectName = 'console-login'
// TODO: start Generalization of pipelines
// TODO: make discussion about when is useful to skip some stages depending the type of the branch
def skippingBranchesRegex = '^(?!(ci|docs|chore|style)/).*$' // this regex will catch feature/fix/perf
def notSkippingBranches = '^((dev|feature|fix|perf|refactor)/.*|rc)$' // this regex will catch feature/fix/perf

pipeline {
    agent { label 'scloud-java-sls' }
    options { 
        ansiColor 'xterm'
        timestamps()
    }
    environment { FORCE_COLOR = 3 }
    stages {
        stage("Init") {
            steps {
                wrapWithGitCredentials({
                    script {
                        skipCI()
                        if (timeUtils.isNightly())
                            buildDescription "Nightly build"
                        jenkinsStage = setServerlessStage()

                    }
                })
            }
        }
        stage('Code') {
            failFast true
            parallel {
                stage("Build") {
                    stages {
                        stage("Compile") {
                            steps {
                                wrapWithArtifactoryCredentials({
                                    sh './gradlew build -Dskip.tests=true -x test -Partifactory_user=${artifactory_user} -Partifactory_password=${artifactory_password}'

                                })
                            }
                        }
                        stage("Unit Tests") {
                            steps {
                                echo "Running unit tests... "
                                sh './gradlew test'
                                script { isTested = true }
                            }
                        }
                        stage("Coverage") {
                            steps {
                                sh './gradlew jacocoTestCoverageVerification'
                                step([$class          : 'JacocoPublisher',
                                      execPattern     : 'build/jacoco/test.exec',
                                      classPattern    : 'build/classes/java/main',
                                      sourcePattern   : 'src/main/java',
                                      exclusionPattern: 'src/test*'])
                            }
                        }
                    }
                }
                stage('Security Code Analysis') {
                    when {
                        anyOf {
                            branch 'release'
                            changeRequest branch: 'rc', target: 'release'
                            allOf {
                                expression { timeUtils.isNightly() }
                                branch 'master'
                            }
                        }
                        beforeOptions true
                        beforeAgent true
                    }
                    agent { label 'scloud-java-sls' }
                    steps {
                        script {
                            def checks = [:]
                            checks['Blackduck'] = {
                                stage('BlackDuck') {
                                    wrapWithArtifactoryCredentials {
                                        blackduck requiredTools: 'GRADLE',
                                                parent: 'Console',
                                                distribution: 'SAAS',
                                                extraArgs: [
                                                        "gradle.build.command=\"build -Dskip.tests=true -x test -Partifactory_user=${artifactory_user} -Partifactory_password=${artifactory_password}\""
                                                ]
                                    }
                                }
                            }
                            checks['Checkmarx'] = {
                                stage('Checkmarx') {
                                    checkmarx()
                                }
                            }
                            parallel checks
                        }
                    }
                }
            }
        }
        stage('Deployment Requirements') {
            when {
                anyOf {
                    allOf {
                        changelog "^.*\\[push-artifact\\].*\$"
                        changeRequest comparator: 'REGEXP', branch: notSkippingBranches, target: 'release|master'
                    }
                    branch comparator: 'REGEXP', pattern: 'master|release'
                    changeRequest branch: skippingBranchesRegex, comparator: 'REGEXP', target: 'master'
                }
                beforeOptions true
                beforeAgent true
            }
            steps {
                npmInstall()
            }
        }
        stage("Deploy") {
            when {
                anyOf {
                    branch 'master'
                    changeRequest branch: skippingBranchesRegex, comparator: 'REGEXP', target: 'master'
                }
                beforeOptions true
                beforeAgent true
            }
            steps {
                wrapWithAwsCredentials {
                    script {
                        if (env.BRANCH_NAME.equals("master")) {
                            lock('scloudConsoleLiveVersionLockResource') {
                            sh "sls deploy --stage ${jenkinsStage} -v"
                            }
                        } else {
                            sh "sls deploy --stage ${jenkinsStage} -v"
                        }
                        deployed = true
                    }
                }
            }
        }
        stage('Component Test') {
            when {
                changeRequest branch: skippingBranchesRegex, comparator: 'REGEXP', target: 'master'
                beforeOptions true
                beforeAgent true
            }
            steps {
                wrapWithAwsCredentials({
                    script {
                        def endpoint = sh(
                                script: "sls info --stage ${jenkinsStage} -v | grep ServiceEndpoint | awk '{print \$2}'",
                                returnStdout: true)
                        sh "gradle sT -DseleniumDriver=phantomjs -DloginEndpoint=${endpoint}"
                    }
                })
            }
        }
        stage('System Test') {
            when {
                branch 'master'
                beforeOptions true
                beforeAgent true
            }
            options {
                warnError('System tests failed')
                lock(resource: 'scloudConsoleLiveVersionLockResource')
            }
            steps {
                script {
                    echo "Triggering job for branch ${env.BRANCH_NAME}"
                    build job: 'scloud/scloud-console_e2e_tests/master/scloud-console_e2e_tests-master-full/master',
                            wait: true,
                            parameters: [
                                    string(name: 'account', value: 'Development'),
                                    string(name: 'endpoint', value: 'https://master.scloudconsole.com')
                            ]
                }
            }
        }
        stage("Build OK") {
            parallel {
                stage("Release") {
                    stages {
                        stage("Versioning") {
                            when {
                                branch comparator: 'REGEXP', pattern: '(rc|master|release)'
                                beforeOptions true
                                beforeAgent true
                            }
                            steps {
                                echo "Semantic Release Should work here"
                                //semanticRelease()
                            }
                        }
                        // TODO: add push to repo to publishCmd of semantic-release so semantic will be in charge of uploading artifact
                        stage("Push to Repository") {
                            when {
                                anyOf {
                                    allOf {
                                        changelog "^.*\\[push-artifact\\].*\$"
                                        changeRequest comparator: 'REGEXP', branch: notSkippingBranches, target: "(release|master)"
                                    }
                                    branch comparator: 'REGEXP', pattern: '(master|release)'
                                }
                                beforeOptions true
                                beforeAgent true
                            }
                            steps {
                                script {
                                    zip zipFile: "${projectName}.zip", glob: archiveGlobs.join(",")
                                    def versionName = getPackageName {
                                        return readYaml(file: './version.yml').version.join(".")
                                    }
                                    pushToRepo repository: "scloud-dist", projectName: projectName, versionName: versionName
                                }
                            }
                        }
                    }
                }
                stage("Clean Up") {
                    when {
                        allOf {
                            expression { deployed }
                            not { branch "master" }
                        }
                        beforeOptions true
                        beforeAgent true
                    }
                    options {
                        warnError("Couldn't remove service from aws")
                    }
                    steps {
                        script {
                            wrapWithAwsCredentials({
                                sh "sls remove -v --stage ${jenkinsStage}"
                            })
                        }
                    }
                }
            }
        }
    post {
        failure {
            script {
                notify.byTeams("release|master", "failed")
                notify.byMail()
            }

        }
        always {
            junit allowEmptyResults: true, testResults: 'build/test-results/**/*.xml'
        }
    }
    }
}
