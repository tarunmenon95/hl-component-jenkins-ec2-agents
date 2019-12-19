CloudFormation do
  
  agent_tags = []
  agent_tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{component_name}") }
  agent_tags << { Key: 'EnvironmentName', Value: Ref(:EnvironmentName) }
  agent_tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }
  agent_tags << { Key: 'cii' }
  IAM_Role(:Role) {
    Path '/'
    AssumeRolePolicyDocument service_assume_role_policy('ec2')
    Policies iam_role_policies(iam_policies)
    Tags agent_tags
  }
  
  InstanceProfile(:InstanceProfile) {
    Path '/'
    Roles [Ref(:Role)]
  }
  
  EC2_SecurityGroup(:SecurityGroup) {
    VpcId Ref(:VPCId)
    GroupDescription FnSub("${EnvironmentName}-#{component_name}")
    SecurityGroupIngress([
      {
        Description: 'ssh access from jenkins master',
        FromPort: 22,
        ToPort: 22,
        IpProtocol: 'TCP',
        SourceSecurityGroupId: Ref(:JenkinsMasterSecurityGroup)
      }
    ])
    SecurityGroupEgress([
      {
        CidrIp: '0.0.0.0/0',
        IpProtocol: '-1'
      }
    ])
    Tags agent_tags
  }
  
  # SSM_Parameter(:LinuxAmi) {
  #   Description "AMI Id for the Jenkins linux agent"
  #   Name FnSub("/ciinabox/${EnvironmentName}/agent/linux/ami")
  #   Tier 'Standard'
  #   Type 'String'
  #   Value Ref(:LinuxAmi)
  #   Tags agent_tags.to_json
  # }
  
  # SSM_Parameter(:WindowsAmi) {
  #   Description "AMI Id for the Jenkins linux agent"
  #   Name FnSub("/ciinabox/${EnvironmentName}/agent/windows/ami")
  #   Tier 'Standard'
  #   Type 'String'
  #   Value Ref(:WindowsAmi)
  #   Tags agent_tags.to_json
  # }
  
  SSM_Parameter(:SubnetsParameter) {
    Description "AMI Id for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/subnets")
    Tier 'Standard'
    Type 'String'
    Value FnJoin(' ', [Ref(:SubnetIds)])
    Tags agent_tags.to_json
  }
  
  SSM_Parameter(:SecurityGroupParameter) {
    Description "AMI Id for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/securitygroup")
    Tier 'Standard'
    Type 'String'
    Value Ref(:SecurityGroup)
    Tags agent_tags.to_json
  }
  
  SSM_Parameter(:InstanceProfileParameter) {
    Description "Instance Profile for the Jenkins linux agent"
    Name FnSub("/ciinabox/${EnvironmentName}/agent/iam")
    Tier 'Standard'
    Type 'String'
    Value FnGetAtt(:InstanceProfile,:Arn)
    Tags agent_tags.to_json
  }
  
end
