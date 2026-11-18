#! /vendor/bin/sh

# Copyright (c) 2012-2013, 2016-2019, The Linux Foundation. All rights reserved.
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

target=`getprop ro.board.platform`

# Apply settings for sm6150
# Set the default IRQ affinity to the silver cluster. When a
# CPU is isolated/hotplugged, the IRQ affinity is adjusted
# to one of the CPU from the default IRQ affinity mask.
echo 3f > /proc/irq/default_smp_affinity

if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=`cat /sys/devices/soc0/soc_id`
else
    soc_id=`cat /sys/devices/system/soc/soc0/id`
fi

case "$soc_id" in
        "355" | "369" | "377" | "380" | "384" )

    # Setting b.L scheduler parameters
    echo 45 > /proc/sys/kernel/sched_downmigrate_boosted
    echo 65 > /proc/sys/kernel/sched_upmigrate_boosted
    echo 65 > /proc/sys/kernel/sched_downmigrate
    echo 85 > /proc/sys/kernel/sched_upmigrate

    # Configure default schedTune value for foreground/top-app
    echo 1 > /dev/stune/foreground/schedtune.prefer_idle
    echo 10 > /dev/stune/top-app/schedtune.boost
    echo 1 > /dev/stune/top-app/schedtune.prefer_idle

    # Enable bus-dcvs
    for device in /sys/devices/platform/soc
    do
        for cpubw in $device/*cpu-cpu-llcc-bw/devfreq/*cpu-cpu-llcc-bw
            do
            echo "bw_hwmon" > $cpubw/governor
            echo "2288 4577 7110 9155 12298 14236" > $cpubw/bw_hwmon/mbps_zones
            echo 4 > $cpubw/bw_hwmon/sample_ms
            echo 68 > $cpubw/bw_hwmon/io_percent
            echo 20 > $cpubw/bw_hwmon/hist_memory
            echo 0 > $cpubw/bw_hwmon/hyst_length
            echo 80 > $cpubw/bw_hwmon/down_thres
            echo 0 > $cpubw/bw_hwmon/guard_band_mbps
            echo 250 > $cpubw/bw_hwmon/up_scale
            echo 1600 > $cpubw/bw_hwmon/idle_mbps
            echo 50 > $cpubw/polling_interval
        done

        for llccbw in $device/*cpu-llcc-ddr-bw/devfreq/*cpu-llcc-ddr-bw
        do
            echo "bw_hwmon" > $llccbw/governor
            echo "1144 1720 2086 2929 3879 5931 6881" > $llccbw/bw_hwmon/mbps_zones
            echo 4 > $llccbw/bw_hwmon/sample_ms
            echo 68 > $llccbw/bw_hwmon/io_percent
            echo 20 > $llccbw/bw_hwmon/hist_memory
            echo 0 > $llccbw/bw_hwmon/hyst_length
            echo 80 > $llccbw/bw_hwmon/down_thres
            echo 0 > $llccbw/bw_hwmon/guard_band_mbps
            echo 250 > $llccbw/bw_hwmon/up_scale
            echo 1600 > $llccbw/bw_hwmon/idle_mbps
            echo 40 > $llccbw/polling_interval
        done

        # Enable mem_latency governor for L3, LLCC, and DDR scaling
        for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
        do
            echo "mem_latency" > $memlat/governor
            echo 10 > $memlat/polling_interval
            echo 400 > $memlat/mem_latency/ratio_ceil
        done

        # Gold L3 ratio ceil
        echo 4000 > /sys/class/devfreq/soc:qcom,cpu6-cpu-l3-lat/mem_latency/ratio_ceil

        # Enable cdspl3 governor for L3 cdsp nodes
        for l3cdsp in $device/*cdsp-cdsp-l3-lat/devfreq/*cdsp-cdsp-l3-lat
        do
            echo "cdspl3" > $l3cdsp/governor
        done

        # Enable compute governor for gold latfloor
        for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
        do
            echo "compute" > $latfloor/governor
            echo 10 > $latfloor/polling_interval
        done
    done

    # cpuset parameters
    echo 0-7     > /dev/cpuset/top-app/cpus
    echo 0-5,7 > /dev/cpuset/foreground/cpus
    echo 4-5     > /dev/cpuset/background/cpus
    echo 2-5     > /dev/cpuset/system-background/cpus
    echo 2-5     > /dev/cpuset/restricted/cpus

    # Enable idle state listener
    echo 1 > /sys/class/drm/card0/device/idle_encoder_mask
    echo 100 > /sys/class/drm/card0/device/idle_timeout_ms

    # Turn on sleep modes.
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
    ;;
esac

case "$soc_id" in
    "365" | "366" )

    # Setting b.L scheduler parameters
    echo 45 > /proc/sys/kernel/sched_downmigrate_boosted
    echo 65 > /proc/sys/kernel/sched_upmigrate_boosted
    echo 65 > /proc/sys/kernel/sched_downmigrate
    echo 85 > /proc/sys/kernel/sched_upmigrate

    # Configure default schedTune value for foreground/top-app
    echo 1 > /dev/stune/foreground/schedtune.prefer_idle
    echo 10 > /dev/stune/top-app/schedtune.boost
    echo 1 > /dev/stune/top-app/schedtune.prefer_idle

    # Enable bus-dcvs
    for device in /sys/devices/platform/soc
    do
        for cpubw in $device/*cpu-cpu-llcc-bw/devfreq/*cpu-cpu-llcc-bw
        do
            echo "bw_hwmon" > $cpubw/governor
            echo "2288 4577 7110 9155 12298 14236" > $cpubw/bw_hwmon/mbps_zones
            echo 4 > $cpubw/bw_hwmon/sample_ms
            echo 68 > $cpubw/bw_hwmon/io_percent
            echo 20 > $cpubw/bw_hwmon/hist_memory
            echo 0 > $cpubw/bw_hwmon/hyst_length
            echo 80 > $cpubw/bw_hwmon/down_thres
            echo 0 > $cpubw/bw_hwmon/guard_band_mbps
            echo 250 > $cpubw/bw_hwmon/up_scale
            echo 1600 > $cpubw/bw_hwmon/idle_mbps
            echo 50 > $cpubw/polling_interval
        done

        for llccbw in $device/*cpu-llcc-ddr-bw/devfreq/*cpu-llcc-ddr-bw
        do
            echo "bw_hwmon" > $llccbw/governor
            echo "1144 1720 2086 2929 3879 5931 6881" > $llccbw/bw_hwmon/mbps_zones
            echo 4 > $llccbw/bw_hwmon/sample_ms
            echo 68 > $llccbw/bw_hwmon/io_percent
            echo 20 > $llccbw/bw_hwmon/hist_memory
            echo 0 > $llccbw/bw_hwmon/hyst_length
            echo 80 > $llccbw/bw_hwmon/down_thres
            echo 0 > $llccbw/bw_hwmon/guard_band_mbps
            echo 250 > $llccbw/bw_hwmon/up_scale
            echo 1600 > $llccbw/bw_hwmon/idle_mbps
            echo 40 > $llccbw/polling_interval
        done

        for npubw in $device/*npu-npu-ddr-bw/devfreq/*npu-npu-ddr-bw
        do
            echo 1 > /sys/devices/virtual/npu/msm_npu/pwr
            echo "bw_hwmon" > $npubw/governor
            echo "1144 1720 2086 2929 3879 5931 6881" > $npubw/bw_hwmon/mbps_zones
            echo 4 > $npubw/bw_hwmon/sample_ms
            echo 80 > $npubw/bw_hwmon/io_percent
            echo 20 > $npubw/bw_hwmon/hist_memory
            echo 10 > $npubw/bw_hwmon/hyst_length
            echo 30 > $npubw/bw_hwmon/down_thres
            echo 0 > $npubw/bw_hwmon/guard_band_mbps
            echo 250 > $npubw/bw_hwmon/up_scale
            echo 0 > $npubw/bw_hwmon/idle_mbps
            echo 40 > $npubw/polling_interval
            echo 0 > /sys/devices/virtual/npu/msm_npu/pwr
        done

        # Enable mem_latency governor for L3, LLCC, and DDR scaling
        for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
        do
            echo "mem_latency" > $memlat/governor
            echo 10 > $memlat/polling_interval
            echo 400 > $memlat/mem_latency/ratio_ceil
        done

        # Gold L3 ratio ceil
        echo 4000 > /sys/class/devfreq/soc:qcom,cpu6-cpu-l3-lat/mem_latency/ratio_ceil

        # Enable cdspl3 governor for L3 cdsp nodes
        for l3cdsp in $device/*cdsp-cdsp-l3-lat/devfreq/*cdsp-cdsp-l3-lat
        do
            echo "cdspl3" > $l3cdsp/governor
        done

        # Enable compute governor for gold latfloor
        for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
        do
            echo "compute" > $latfloor/governor
            echo 10 > $latfloor/polling_interval
        done
    done

    # cpuset parameters
    echo 0-7     > /dev/cpuset/top-app/cpus
    echo 0-5,7 > /dev/cpuset/foreground/cpus
    echo 4-5     > /dev/cpuset/background/cpus
    echo 2-5     > /dev/cpuset/system-background/cpus
    echo 2-5     > /dev/cpuset/restricted/cpus

    # Enable idle state listener
    echo 1 > /sys/class/drm/card0/device/idle_encoder_mask
    echo 100 > /sys/class/drm/card0/device/idle_timeout_ms

    # Turn on sleep modes.
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
    ;;
esac

    # BORE Scheduler tunning
    echo 1 > /proc/sys/kernel/sched_child_runs_first
    echo 8000000 > /proc/sys/kernel/sched_burst_cache_lifetime
    echo 2 > /proc/sys/kernel/sched_burst_fork_atavistic
    echo 12 > /proc/sys/kernel/sched_burst_penalty_offset
    echo 750 > /proc/sys/kernel/sched_burst_penalty_scale
    echo 1 > /proc/sys/kernel/sched_burst_smoothness_long
    echo 1 > /proc/sys/kernel/sched_burst_smoothness_short
    echo 980000 > /proc/sys/kernel/sched_rt_runtime_us
    echo 1000000 > /proc/sys/kernel/sched_rt_period_us
    echo 50 > /proc/sys/kernel/sched_rr_timeslice_ms
    
    # Manipulated Memory Management
    echo 160 > /proc/sys/vm/swappiness
    echo 35 > /proc/sys/vm/watermark_scale_factor
    echo 30 > /proc/sys/vm/dirty_ratio
    echo 10 > /proc/sys/vm/dirty_background_ratio
    echo 150 > /proc/sys/vm/dirty_writeback_centisecs
    echo 1500 > /proc/sys/vm/dirty_expire_centisecs
    echo 131072 > /proc/sys/vm/extra_free_kbytes
    echo 32768 > /proc/sys/vm/min_free_kbytes
    echo 1 > /proc/sys/vm/overcommit_memory
    echo 80 > /proc/sys/vm/overcommit_ratio
    echo 1 > /proc/sys/vm/oom_kill_allocating_task
    echo 0 > /proc/sys/vm/oom_dump_tasks
    echo 0 > /proc/sys/vm/page-cluster

# Enable PowerHAL hint processing
setprop vendor.powerhal.init 1

setprop vendor.post_boot.parsed 1
