### Install postgis  

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bionic-pgdg main" >> /etc/apt/sources.list'
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -

# list of versions
# sudo apt-cache policy postgis

sudo apt install -y postgis=2.4.3+dfsg-4  --no-install-recommends
sudo apt install -y postgresql-10
sudo apt install -y postgresql-10-postgis-2.4 
sudo apt install -y postgresql-10-postgis-scripts
sudo apt install -y postgis
sudo apt install -y postgresql-10-pgrouting

# su - postgres psql -c "CREATE EXTENSION adminpack;"

### install GDAL and libgeos++-dev
sudo apt install -y libgdal-dev libproj-dev 
sudo apt install -y libgeos++-dev

#### install R 3.6
sudo sh -c 'echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo apt update
sudo apt install -y r-base
sudo apt install -y r-base-dev  


# upgrade
sudo apt update -y 

# Prevents GRUB issues 
# Ubuntu 18.04.4 LTS
# https://www.digitalocean.com/community/questions/ubuntu-new-boot-grub-menu-lst-after-apt-get-upgrade?answer=45153
sudo rm /boot/grub/menu.lst
sudo update-grub-legacy-ec2 -y

sudo apt upgrade -y

### install R packages

# Shiny
sudo su - \
-c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""

# Shiny packages
sudo su - \
-c "R -e \"install.packages(c('shinydashboard','shinyWidgets','shinythemes','DT'), repos='https://cran.rstudio.com/')\""

# Database packages
sudo su - \
-c "R -e \"install.packages(c('pool','rpostgis','RPostgres','DBI'), repos='https://cran.rstudio.com/')\""

# graph network packages
sudo su - \
-c "R -e \"install.packages(c('igraph','visNetwork'), repos='https://cran.rstudio.com/')\""

# data manipulation packages
sudo su - \
-c "R -e \"install.packages(c('scales','dplyr'), repos='https://cran.rstudio.com/')\""

# plotting packages
sudo su - \
-c "R -e \"install.packages(c('wesanderson','ggplot2','ggthemes', 'plotly'), repos='https://cran.rstudio.com/')\""


### install git 
#sudo apt install -y git

### install Shiny-Server
sudo apt install -y gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb
sudo gdebi -n shiny-server-1.5.14.948-amd64.deb


# configure UFW  
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 3838
sudo ufw allow 5432

# personal ip
#sudo ufw allow from 73.118.80.0/24

wget https://github.com/sethbassett/cadastral_crawler/archive/dev.zip -O git.zip
unzip git.zip -d /srv/shiny-server/cadcrawler
sudo chown shiny







