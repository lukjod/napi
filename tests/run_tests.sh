#!/bin/bash

path_root="/home/vagrant";

vagrant up

# prepare the environment
time vagrant ssh -c "/vagrant/tests/prepare_gcc3.sh $path_root"
time vagrant ssh -c "cd /vagrant/tests && ./prepare.pl $path_root"

# run unit tests
vagrant ssh -c "cd /vagrant/tests && ./unit_napi.sh $path_root"
uni_status=$?

if [ $uni_status -ne 0 ]; then
	echo '==========================================='
	echo 'NAPI.SH - UNIT TESTY NIE POMYSLNE !!!'
	echo 'SYSTEM TESTY NIE ZOSTANA PRZEPROWADZONE !!!'
	echo '==========================================='
	exit -1
fi

# run system tests with the following shells
declare -a shells=( 'bash-2.04' 'bash-2.05' 'bash-2.05a' 'bash-2.05b' 'bash-3.0' 'bash-3.1' 'bash-3.2' 'bash-3.2.48' 'bash-4.0' 'bash-4.1' 'bash-4.2' 'bash-4.3' )

for s in "${shells[@]}"; do
	echo '==========================================='
	echo "TESTUJE Z SHELLEM ($s)"
	echo '==========================================='
	
	vagrant ssh -c "cd /vagrant/tests && NAPI_TEST_SHELL=$path_root/shells_bin/$s prove"
	sys_status=$?

	if [ $sys_status -ne 0 ]; then
		echo '==========================================='
		echo "SYSTEM TESTY NIEPOMYSLNE Z SHELLEM ($s)"
		echo '==========================================='
		exit -1
	fi
done


echo '==========================================='
echo 'WSZYSTKIE TESTY ZAKONCZONE POMYSLNIE'
echo '==========================================='


# hibernate the VM
vagrant suspend
