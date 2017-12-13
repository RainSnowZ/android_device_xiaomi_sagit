#!/system/bin/sh
# Copyright (c) 2012-2013, 2016, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# Configure core ctl
echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
echo 60 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
echo 30 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres

# Enable Adaptive LMK
echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo "18432,23040,27648,51256,150296,200640" > /sys/module/lowmemorykiller/parameters/minfree
echo 162500 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min

# Setting b.L scheduler parameters
echo 1 > /proc/sys/kernel/sched_migration_fixup
echo 95 > /proc/sys/kernel/sched_upmigrate
echo 90 > /proc/sys/kernel/sched_downmigrate
echo 100 > /proc/sys/kernel/sched_group_upmigrate
echo 95 > /proc/sys/kernel/sched_group_downmigrate
echo 0 > /proc/sys/kernel/sched_select_prev_cpu_us
echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
echo 400000 > /proc/sys/kernel/sched_freq_dec_notify
echo 5 > /proc/sys/kernel/sched_spill_nr_run
echo 1 > /proc/sys/kernel/sched_restrict_cluster_spill

# Disable thermal bcl hotplug to switch governor
echo 0 > /sys/module/msm_thermal/core_control/enabled

# Online CPU0 and CPU4
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu4/online

available_governors=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`

if [[ "$available_governors" == *"schedutil"* ]]; then
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 500 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us
    echo 20000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us
    echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 500 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us
    echo 20000 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us
    echo 1 > /dev/stune/foreground/schedtune.prefer_idle
    echo 10 > /dev/stune/top-app/schedtune.boost
    echo 1 > /dev/stune/top-app/schedtune.prefer_idle
    setprop sys.use_fifo_ui 1
elif [[ "$available_governors" == *"sched"* ]]; then
    echo "sched" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "sched" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    setprop sys.use_fifo_ui 1
else
    # Configure governor settings for little cluster
    echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
    echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
    echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
    echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
    echo 1248000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
    echo "83 1804800:95" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
    echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
    echo 79000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
    echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif

    # Configure governor settings for big cluster
    echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
    echo 19000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
    echo 90 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
    echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
    echo 1574400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
    echo "83 1939200:90 2016000:95" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
    echo 19000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
    echo 79000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
    echo 300000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/ignore_hispeed_on_notif
fi

# Enable thermal and BCL hotplug
echo 1 > /sys/module/msm_thermal/core_control/enabled

# Enable input boost configuration
echo "0:1324800" > /sys/module/cpu_boost/parameters/input_boost_freq
echo 100 > /sys/module/cpu_boost/parameters/input_boost_ms

# Enable bus-dcvs
for cpubw in /sys/class/devfreq/*qcom,cpubw*
do
    echo "bw_hwmon" > $cpubw/governor
    echo 50 > $cpubw/polling_interval
    echo 1525 > $cpubw/min_freq
    echo "3143 5859 11863 13763" > $cpubw/bw_hwmon/mbps_zones
    echo 4 > $cpubw/bw_hwmon/sample_ms
    echo 34 > $cpubw/bw_hwmon/io_percent
    echo 20 > $cpubw/bw_hwmon/hist_memory
    echo 10 > $cpubw/bw_hwmon/hyst_length
    echo 0 > $cpubw/bw_hwmon/low_power_ceil_mbps
    echo 34 > $cpubw/bw_hwmon/low_power_io_percent
    echo 20 > $cpubw/bw_hwmon/low_power_delay
    echo 0 > $cpubw/bw_hwmon/guard_band_mbps
    echo 250 > $cpubw/bw_hwmon/up_scale
    echo 1600 > $cpubw/bw_hwmon/idle_mbps
done

for memlat in /sys/class/devfreq/*qcom,memlat-cpu*
do
    echo "mem_latency" > $memlat/governor
    echo 10 > $memlat/polling_interval
    echo 400 > $memlat/mem_latency/ratio_ceil
done

echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor

echo N > /sys/module/lpm_levels/system/pwr/cpu0/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/cpu1/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/cpu2/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/cpu3/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu4/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu5/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu6/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu7/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-dynret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/perf-l2-dynret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/perf-l2-ret/idle_enabled
echo N > /sys/module/lpm_levels/parameters/sleep_disabled
echo 0 > /proc/sys/kernel/sched_boost
