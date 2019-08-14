aws_vpc_id = input('aws_vpc_id')
sshkey = input('sshkey')
aws_security_group = input('aws_security_group')
aws_subnets = input('aws_subnets')
instance_name = input('inst_name_tag')
asg_name = input('asg_name')


# describe aws_iam_role('alz-svm-pipelinerole') do
#   it { should exist }
# end

# describe aws_organizations_member do
#   its('account_name')  { should eq 'shared-services' }
#   its('account_email') { should eq 'bhge-aws-shared-services-account@ge.com' }
# end

describe aws_vpc(aws_vpc_id) do
  it { should exist }
end

aws_subnets.each do |subnet|
  describe aws_subnet(subnet_id: subnet) do
    it { should exist }
    # its('cidr_block') { should eq '10.0.1.0/24' }
  end
end

aws_security_group.each do |sg|
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
    its('tags') { should include(key: 'Name', value: instance_name) }
  end
end

describe aws_auto_scaling_group(asg_name) do
  it { should exist }
  its('min_size') { should be 2}
  its('max_size') { should be 2}
end
