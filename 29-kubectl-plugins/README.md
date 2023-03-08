https://krew.sigs.k8s.io/plugins/

Most useful personally:

https://github.com/kvaps/kubectl-node-shell  
https://github.com/hidetatz/kubecolor  
https://github.com/stern/stern  


DYFF
https://github.com/homeport/dyff

$ brew install homeport/tap/dyff

$ dyff between \
https://raw.githubusercontent.com/cloudfoundry/cf-deployment/v1.10.0/cf-deployment.yml \
https://raw.githubusercontent.com/cloudfoundry/cf-deployment/v1.20.0/cf-deployment.yml

$ KUBECTL_EXTERNAL_DIFF=dyff between --omit-header --set-exit-code

$ kubectl diff -f [yaml_file]