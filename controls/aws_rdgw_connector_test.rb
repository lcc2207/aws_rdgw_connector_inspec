# inspec exec alz-profile -t aws://

# describe aws_iam_role('alz-svm-pipelinerole') do
#   it { should exist }
# end

# describe aws_organizations_member do
#   its('account_name')  { should eq 'shared-services' }
#   its('account_email') { should eq 'bhge-aws-shared-services-account@ge.com' }
# end
vpcid = 'vpc-0e95d91ddf4e29119'
sshkey = 'lz_837098563121_us-east-1_2019-05-29T15-38-23'

describe aws_vpc(vpcid) do
  it { should exist }
end

describe aws_subnets.where(vpc_id: vpcid) do
  its('subnet_ids') { should include 'subnet-006d0caaaaedb2488' }
  its('subnet_ids') { should include 'subnet-078f7f07d73437d5e' }
  its('subnet_ids') { should include 'subnet-0c68d99bd77d3c522' }
end

%w(StackSet-AWS-Landing-Zone-SharedServicesActiveDirectory-47dd365e-e0e2-4d81-9e5b-4b2e16510d1a-DomainMemberSG-1KRF038Y4WC1F StackSet-AWS-Landing-Zone-SharedServicesRDGW-17bcc4ff-75ad-4d26-9409-ba3099dd69ec-RemoteDesktopGatewaySG-1922SUJ8YCOD).each do |sg|
  describe aws_security_group(group_name: sg) do
    it { should exist }
    # it { should allow_in(port: 22, ipv4_range: '10.5.0.0/16') }
    it { should_not allow_in(port: 22, ipv4_range: '0.0.0.0/0') }
  end
end


aws_ec2_instances.instance_ids.each do |instance_id|
  describe aws_ec2_instance(instance_id) do
    it { should be_running }
    its('key_name') { should cmp sshkey }
  end
end
