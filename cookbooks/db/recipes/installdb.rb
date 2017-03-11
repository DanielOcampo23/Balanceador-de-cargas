package 'mysql-server'
service 'mysqld' do
action [:enable, :start]
end

bash 'open port' do
  code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
  service iptables save
  EOH
end

package 'expect'

cookbook_file '/tmp/configure_mysql.sh' do
  source 'configure_mysql.sh'
  mode 0711
end

cookbook_file '/tmp/create_schema.sql' do
  source 'create_schema.sql'
  mode 0711
end

bash 'configure mysql' do
  cwd '/tmp'
  code <<-EOH
  ./configure_mysql.sh
  EOH
end

template '/tmp/create_schema.sql' do
  source 'create_schema.sql.erb'
  variables(
   usuario: node[:db][:user],
   ip: node[:db][:ip],
   ip2: node[:db][:ip2],
   password: node[:db][:password]	
)
end

bash 'create schema' do
cwd '/tmp'  
code <<-EOH
 cat create_schema.sql | mysql -u root -pdistribuidos
  EOH
end
