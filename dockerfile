FROM ubuntu:20.04

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt update && apt install -y curl gnupg2 lsb-release
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y ros-foxy-desktop

RUN apt update && apt-get install git -y
WORKDIR /root/dev_ws/src
RUN git clone https://github.com/ros/ros_tutorials.git -b foxy-devel
WORKDIR /root/dev_ws

RUN apt-get install python3-rosdep -y
RUN rosdep init
RUN rosdep update
RUN rosdep install -i --from-path src --rosdistro foxy -y
RUN apt install python3-colcon-common-extensions -y

COPY ros2_entrypoint.sh /root/.
ENTRYPOINT ["/root/ros2_entrypoint.sh"]
CMD ["bash"]

WORKDIR /root/dev_ws/src
RUN ros2 pkg create --build-type ament_cmake cpu_load
WORKDIR /root/dev_ws/src/cpu_load
RUN git clone https://github.com/vitorHoller/ROS2-CPU_load
RUN colcon build --packages-select cpu_load
RUN . install/setup.bash
WORKDIR /root/dev_ws/
RUN ros2 run cpu_load cpu
#move to src
#create package
#move to pkg src
#clone from git
#back to dev_ws and ros2 run <package> <node>
