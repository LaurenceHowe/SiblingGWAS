dpkg -l | grep "^ii  r-" > r_packages.txt

cat <<EOF | sudo tee /etc/apt/preferences.d/pin-r35
Package: r-*
Pin: release a=xenial-cran35
Pin: version 3.5*
Pin-Priority: 800

Package: r-cran-nlme
Pin: release a=xenial-cran35
Pin: version 3.1.139-1xenial0
Pin-Priority: 800
EOF

sudo apt purge r-*
sudo apt autoremove

sudo apt-get install $(cat r_packages.txt | awk '{print $2}')

