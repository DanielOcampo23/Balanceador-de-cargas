# Balanceador de cargas
Balanceador de cargas automatizado 

Daniel Steven Ocampo
14103032

# Objetivos

Realizar de forma autónoma el aprovisionamiento automático de infraestructura
Diagnosticar y ejecutar de forma autónoma las acciones necesarias para lograr infraestructuras estables
Integrar servicios ejecutandose en nodos distintos

# Prerrequisitos

Vagrant
Box del sistema operativo CentOS 6.5 o superior

# Descripción del problema a solucionar

Deberá realizar el aprovisionamiento de un ambiente compuesto por los siguientes elementos: un servidor encargado de realizar balanceo de carga, dos servidores web (puede emplear apache+php o crear un servicio web con el lenguaje de su preferencia) y un servidor de base de datos (postgresql o mysql). Se debe probar el funcionamiento del balanceador a través de una aplicación web que realice consultas a la base de datos a través de los servidores web (mostrar visualmente cual servidor web atiende la petición)

# Arquitectura del problema

![01_diagrama_despliegue](https://cloud.githubusercontent.com/assets/23728734/23819964/8cacf2ea-05dc-11e7-8e31-656d16be84d7.png)

# Desarrollo

Para poder desarrollar esta actividad se escogió como servidor el programa Nginx para que tome el rol de balanceador de cargas, ya que en la red lo sugieren como uno de los mejores sistemas para realizar dicha actividad.

# Instalación de Nginx como balanceador de cargas

1. Para poder instalar el Nginx se requiere añadir el repositorio de los desarrolladores de Nginx, eso se necesita para poder obtener la última versión estable de Nginx, ya que el repositorio de Centos puede tener una version obsoleta o puede presentar problemas al intentar obtener las librerias requeridas para su instalación. Para agregar este repositorio es necesario crear el archivo `nginx.repo` en la ruta `/etc/yum.repos.d/` y agregar las siguientes lineas en este archivo


```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```
Para mayor información visitar la página oficial de Nginx https://www.nginx.com/resources/wiki/start/topics/tutorials/install/

2. Ejecutar el siguiente comando en la terminar para realizar la instalación 
```
yum -y install nginx
```

3. Realizar la apertura del puerto 8080 en el cual se va a levantar el servicio del balanceador de carga, utilizando la utilidad iptables
```
iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
```

4. Guardar la configuración del iptables
```
service iptables save
```

5. Para poder que el Nginx pueda redireccionar correctamente las peticiones hacia los dos servidores web descriptos en el Diagrama de deployment mostrado anteriormente. para esto se debe modificar el archivo de configuración de Ngnix que se encuentra en la ruta `/etc/nginx/nginx.conf` 

```
worker_processes  1;
events {
   worker_connections 1024;
}

http {
    upstream servers {
         server 192.168.131.57;
         server 192.168.131.58;
    }

    server {
        listen 8080;

        location / {
              proxy_pass http://servers;
        }
    }
}
```

6. Antes de levantar el servicion de Nginx primero garantizamos de que no haya ningun servidor web apache corriendo en la maquina, para esto ejecutamos el siguiente comando
```
service httpd stop 
```

7. Inicializamos el servicio de Nginx
```
nginx
```

# Automatización del sistema

Los comandos anteriormente mencionados son utilizados para configurar paso a paso un balanceador de cargas con Nginx en un sistema operativo centos, podemos realizar la automatización de estos comandos utilizando la herramienta Vagrant, con esto podemos crear y configurar automaticamente entornos de desarrollo en máquinas virtuales.
Para nuestro ejecicio vamos a configurar cuatro máquinas virtuales: dos máquinas virtuales donde se van alojar los servidores web (Apache), 1 máquina virtual para la base de datos (Mysql), y una máquina virtual para el balanceador de cargas (nginx).
Las 3 primeras máquinas virtuales se trabajaron en clases previas, en esta sección vamos a exponer la automatización de la última máquina virtual (balanceador de cargas con nginx)

1. Configuración del archivo VagrantFile
En este archivo es donde se especifican las configuraciones iniciales para levantar las 4 maquinas virtuales de manera automatica (Nombre de la máquina, box del sistema operativo, ip privada y publica de la maquina, los recursos con los que va a trabajar la máquina virtual, y la ruta donde se encuentran las recetas, los archivos, los atributos, y los templates). Estas máquinas virtuales serán levantas utilizando VirtualBox.

A continuación se expone el VagrantFile utilizado en nuestro ejercicio.

```
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  config.vm.define :centos_web do |web|
    web.vm.box = "Centos64Update"
    web.vm.network "private_network", ip: "192.168.33.55"
    web.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.57"
    web.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-web" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "web"
    end
  end

 config.vm.define :centos_web2 do |web2|
    web2.vm.box = "Centos64Update"
    web2.vm.network "private_network", ip: "192.168.33.56"
    web2.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.58"
    web2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-web2" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "web2"
    end
  end

  config.vm.define :centos_db do |db|
    db.vm.box = "Centos64Update"
    db.vm.network "private_network", ip: "192.168.33.57"
    db.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.59"
    db.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-db" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "db"
    end
  end


config.vm.define :centos_bc do |bc|
    bc.vm.box = "Centos64Update"
    bc.vm.network "private_network", ip: "192.168.33.58"
    bc.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.56"
    bc.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-bc" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "bc"
    end
  end
end	
```

2. Configuración de los cookbooks para la máquina balanceadora de cargas

A continuación mostraré únicamente el arbol de carpetas de la máquina que esta encargada de hacer el balanceo de cargas

![tree bc](https://cloud.githubusercontent.com/assets/23728734/23819629/d014f9ac-05d6-11e7-9c76-980e3e491763.png)

Se copio el diseño de la estructura de las carpetas de las demas máquinas virtuales trabajadas en clase previamente, para seguir el orden en la estructura de esta máquina virtual

En la carpeta attributes, hay un archivo llamado "default.rb" en el cual se establecen las variables utilizadas en las demas configuraciones que se mostrarán proximamente, esto es para facilitar cambios a futuro, mendiante la ayuda de variables

En la carpeta recipes, existen 2 archivos, el primero llamado "default.rb" el cual simplemente hace el llamado al segundo archivo llamado "installbc.rb" con el siguiente código `include_recipe 'bc::installbc'`. En el segundo archivo, se verán los comandos anteriormente mencionados en esta guia, pero de manera automatizada

```
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
```
En este vemos todos los pasos previamente explicados, pero para ser ejecutados de manera automatica. También se puede ver como en archivo hace llamado a la siguiente carpeta que explicaré a continuación.

De manera ordenada continuamos con las siguientes carpetas llamadas templates/default y con dos archivos, llamados "nginx.conf.erb" y "nginx.repo.erb "en el cual esta el código mencionado anteriormente en paso numero 5 y numero 7 respectivamente, pero como forma recetas, y con sus respectivas variables.

3. Aprovicionamiento de manera automatica mendiante vagrant

Después de configurar, el VagrantFile, y las recetas de cada una de las carpetas de "cookbooks" correctamente, procedemos a ubicarnos en la carpeta donde esta almacenada el archivo "Vagratfile" y a continuación ejecutamos el comando `vagrant up`, el cual de manera automatica comienza a levantar las cuatro máquinas virtuales con sus respectivas especificaciones configuradas en el vagrantfile de manera automatica

# Evidencia del funcionamiento del balanceador de cargas 


# Problemas presentados durante el desarrollo de la actividad

El primer problema presentado durante el desarrollo de esta actividad, fue al tratar de instalar nginx ya que como anteriormente lo mencionaba para poder hacer la correcta instalación toca cambiar el repositorio, o si no el trata de descargar las configuraciones del repositorio que tiene por defecto y durante la instalación ocurre el error.

El segundo problema presentado fue 



# Conclusión
