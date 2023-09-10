## tekton 체험해보기

### EKS 환경
1. test 환경이 겹치지 않으려면 main.tf에 있는 locals의 id와 env 변수를 변경하고 main.tf와 같은 경로에 secret.auto.tfvars 파일을 만들어서 aws_access_key_id와 aws_secret_key_id를 각각 입력해주어야 합니다.2
2. test instance에서 aws eks update-kubeconfig --name \[eks cluster name\]을 통해 test instance에서 kubectl 명령을 날릴 수 있도록 합니다.
3. vpc, subnet cidr은 main.tf에서 설정할 수 있으며, 만들어진 public subnet만큼 nat gateway가 생성되므로 public subnet을 많이 생성하는 것은 권장하지 않습니다.
4. main.tf의 eks module 부분에서 eks version과 instance type, instance에 접근할 수 있는 key name을 설정할 수 있습니다.
5. k8s module에서 ebs csi driver와 aws load balancer controller를 자동으로 설치하도록 설정해두었으며, ebs csi driver는 tekton에서 pvc를 사용하기 때문에 필요하고 aws load balancer controller는 dashboard를 외부에 노출시키기 위해 필요합니다.

### Tekton 설치 과정
1. install tekton pipeline
https://tekton.dev/docs/installation/pipelines/을 참고하여 최신버전의 tekton pipeline을 설치하는 명령어를 입력합니다.  
`kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml`
2. install tekton dashboard
https://tekton.dev/docs/dashboard/install/을 참고하여 최신버전의 tekton dashboard를 설치하는 명령어를 입력합니다. 
`kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml`
3. tkn 설치 
https://tekton.dev/docs/cli/을 참고하여 linux ec2에 최신버전의 tkn cli를 설치하는 명령어를 입력합니다.  
```
# Get the tar.xz
curl -LO https://github.com/tektoncd/cli/releases/download/v0.31.2/tkn_0.31.2_Linux_x86_64.tar.gz
# Extract tkn to your PATH (e.g. /usr/local/bin)
sudo tar xvzf tkn_0.31.2_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
```
4. install tekton dashboard ingress
/k8s/tekton/tekton-ingress.yaml 경로에서 코드를 가져와 설치합니다. (alb는 subnet을 최소 두 개 이상 사용할 수 있어야 합니다.)  
`kubectl apply -f tekton-ingress.yaml`
5. install pvc for tekton
/k8s/tekton/tekton-pvc.yaml 경로에서 코드를 가져와 설치합니다.  
`kubectl apply -f tekton-pvc.yaml`
6. github repo에 있는 소스 tekton pvc로 가져오는 pipeline 구성
https://hub.tekton.dev/?query=git+clone을 참고하여 git repository에서 readme.md를 가져오는 task를 다운로드합니다.  
`kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml`  
이후, /k8s/tekton/tekton-pipeline.yaml에서 코드를 가져와 설치합니다. 
(주의: kubectl create -f) 
`kubectl create -f tekton-pipeline.yaml`
7. dashboard check
dashboard에서 pipeline이 잘 실행되었는지 확인합니다.
8. pvc check
/k8s/tekton/test-pod.yaml에서 코드를 가져와 설치합니다. test용 pod를 만들어 pvc에 readme.md가 잘 가져와져있는지 확인합니다.  
`kubectl apply -f test-pod.yaml`  
`kubectl exec -it test -- /bin/bash`  
`ls /test`  
9. 아래 link를 활용하여 tekton trigger를 설치합니다.  
'''
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
'''