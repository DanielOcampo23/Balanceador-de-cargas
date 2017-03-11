template '/etc/yum.repos.d/nginx.repo' do
  source 'nginx.repo.erb'
end


bash 'install nginx' do
code <<-EOH
 yum -y install nginx
  EOH
end

bash 'open port' do
  code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
  service iptables save
  EOH
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  variables(
   ip: node[:bc][:ip],
   ip2: node[:bc][:ip2]	
)
end

bash 'run nginx' do
code <<-EOH
 service httpd stop
 nginx
  EOH
end

