node {
   stage ("Ant Project"){
   echo 'Starting Ant Build..'
   build 'ant-github-jenkins'
   echo 'Ant Build finished..'
   }
   stage ("Maven Project"){
   input message: 'Please Enter Maven Project Version', parameters: [string(defaultValue: '1.0-SNAPSHOT', description: 'Maven Project Version', name: 'version')]
   echo 'Starting Maven Build..'
   sh 'echo ${version}'
   build 'maven-github-jenkins'
   echo 'Done with Maven Build..'
   }
   stage ("Moving Artifacts"){
   echo 'Moving Artifacts to user content..'
   sh 'rm -rf ~/userContent/*;'
   sh 'find /var/lib/jenkins/workspace -name *.jar -exec cp {} ~/userContent/ \;'
   echo 'Artifacts available at http://192.168.33.10:8080/userContent/..'
   }
}