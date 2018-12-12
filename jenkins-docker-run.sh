sudo docker run -it --name con_blueocean_jenkins --rm \
	-v /home/jenkins/Jenkins_Storage_BlueOcean:/var/lib/jenkins \
	-v /home/jenkins/External_toolchain:/opt/crosstools \
	-p 8100:8080 -p 58100:50000 \
        --env JAVA_OPTS='-Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -Duser.timezone=Asia/Seoul' \
        --env JENKINS_JAVA_OPTIONS='-Duser.timezone=Asia/Seoul -Duser.country=KR' \
	--env TOOLCHAIN_ARM_CORTEX_A9='/opt/crosstools/arm-cortex_a9-eabi-4.7-eglibc-2.18' \
	--env TOOLCHAIN_GCC_LINARO_AARCH64='/opt/crosstools/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu' \
	--env TOOLCHAIN_ARM_EABI='/opt/crosstools/arm-eabi-4.8' \
	--env LC_ALL='en_US.UTF-8' \
	--env LANG='en_US.UTF-8' \
	--env LANGUAGE='en_US.UTF-8' \
	nexelldocker/jenkins-blueocean-ubuntu

