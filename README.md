# Balanceador de cargas
Balanceador de cargas automatizado 

Daniel Steven Ocampo

14103032

https://github.com/DanielOcampo23/Balanceador-de-cargas

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

- Para poder instalar el Nginx se requiere añadir el repositorio de los desarrolladores de Nginx, eso se necesita para poder obtener la última versión estable de Nginx, ya que el repositorio de Centos puede tener una versión obsoleta o puede presentar problemas al intentar obtener las librerías requeridas para su instalación. Para agregar este repositorio es necesario crear el archivo `nginx.repo` en la ruta `/etc/yum.repos.d/` y agregar las siguientes líneas en este archivo.


```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```
Para mayor información visitar la página oficial de Nginx https://www.nginx.com/resources/wiki/start/topics/tutorials/install/

- Ejecutar el siguiente comando en la terminar para realizar la instalación 
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

5. Para poder que el Nginx pueda re direccionar correctamente las peticiones hacia los dos servidores web descriptos en el Diagrama de deployment mostrado anteriormente. Para esto se debe modificar el archivo de configuración de Ngnix que se encuentra en la ruta `/etc/nginx/nginx.conf` 

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

6. Antes de levantar el servicio de Nginx primero garantizamos de que no haya ningún servidor web apache corriendo en la máquina, para esto ejecutamos el siguiente comando
```
service httpd stop 
```

7. Inicializamos el servicio de Nginx
```
nginx
```

# Automatización del sistema

Los comandos anteriormente mencionados son utilizados para configurar paso a paso un balanceador de cargas con Nginx en un sistema operativo centos, podemos realizar la automatización de estos comandos utilizando la herramienta Vagrant, con esto podemos crear y configurar automáticamente entornos de desarrollo en máquinas virtuales.
Para nuestro ejercicio vamos a configurar cuatro máquinas virtuales: dos máquinas virtuales donde se van alojar los servidores web (Apache), 1 máquina virtual para la base de datos (Mysql), y una máquina virtual para el balanceador de cargas (nginx).
Las 3 primeras máquinas virtuales se trabajaron en clases previas, en esta sección vamos a exponer la automatización de la última máquina virtual (balanceador de cargas con nginx)

1. Configuración del archivo VagrantFile
En este archivo es donde se especifican las configuraciones iniciales para levantar las 4 maquinas virtuales de manera automática (Nombre de la máquina, box del sistema operativo, ip privada y publica de la maquina, los recursos con los que va a trabajar la máquina virtual, y la ruta donde se encuentran las recetas, los archivos, los atributos, y los templates). Estas máquinas virtuales serán levantas utilizando VirtualBox.

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

A continuación mostraré únicamente el árbol de carpetas de la máquina que esta encargada de hacer el balanceo de cargas

![tree bc](https://cloud.githubusercontent.com/assets/23728734/23819629/d014f9ac-05d6-11e7-9c76-980e3e491763.png)

Se copio el diseño de la estructura de las carpetas de las demás máquinas virtuales trabajadas en clase previamente, para seguir el orden en la estructura de esta máquina virtual

En la carpeta attributes, hay un archivo llamado "default.rb" en el cual se establecen las variables utilizadas en las demás configuraciones que se mostrarán proximamente, esto es para facilitar cambios a futuro, mediante la ayuda de variables

En la carpeta recipes, existen 2 archivos, el primero llamado "default.rb" el cual simplemente hace el llamado al segundo archivo llamado "installbc.rb" con el siguiente código `include_recipe 'bc::installbc'`. En el segundo archivo, se verán los comandos anteriormente mencionados en esta guía, pero de manera automatizada

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
En este vemos todos los pasos previamente explicados, pero para ser ejecutados de manera automática. También se puede ver como en archivo hace llamado a la siguiente carpeta que explicaré a continuación.

De manera ordenada continuamos con las siguientes carpetas llamadas templates/default y con dos archivos, llamados "nginx.conf.erb" y "nginx.repo.erb "en el cual esta el código mencionado anteriormente en paso numero 5 y numero 7 respectivamente, pero como forma recetas, y con sus respectivas variables.

3. Aprovisionamiento de manera automática mediante vagrant

Después de configurar, el VagrantFile, y las recetas de cada una de las carpetas de "cookbooks" correctamente, procedemos a ubicarnos en la carpeta donde esta almacenada el archivo "Vagratfile" y a continuación ejecutamos el comando `vagrant up`, el cual de manera automática comienza a levantar las cuatro máquinas virtuales con sus respectivas especificaciones configuradas en el vagrantfile de manera automática

# Evidencia del funcionamiento del balanceador de cargas 

![pruebagiff2](https://cloud.githubusercontent.com/assets/23728734/23819979/b9882fd2-05dc-11e7-80e7-c52e3d1e9a33.gif)

# Problemas presentados durante el desarrollo de la actividad

El primer problema presentado durante el desarrollo de esta actividad, fue al tratar de instalar nginx ya que como anteriormente lo mencionaba para poder hacer la correcta instalación es necesario cambiar el repositorio, si no el sistema trata de descargar las configuraciones del repositorio que tiene por defecto y durante la instalación ocurre el error, ya que no se encontraron las dependencias de este software.

El segundo problema presentado fue el poco conocimiento del php, por lo cual tuve que ver un pequeño tutorial en youtube para poder aprender lo basico para poder configurar algunas recetas.

El tercer problema fue aprender los comandos para realizar la automatización de la instalación y la configuración del Nginx, como manejar las variables de los templates, ejecutar comandos bash en la máquina virtual automáticamente.


# Conclusión

Mediante esta actividad, aprendí la importancia de automatizar los sistemas mediante los servicios que nos da vagrant. Este entorno nos permite un desarrollo mucho más optimizado, ya que cada vez que necesitemos el balanceador de cargas únicamente tenemos que aprovisionar y listo. 
Por otro lado el balanceador de cargas es un componente muy importante en la arquitectura de software ya que esto cuando se implementa en un sistema grande, nos esta garantizando la escalabilidad y la disponiblidad del sistema.
