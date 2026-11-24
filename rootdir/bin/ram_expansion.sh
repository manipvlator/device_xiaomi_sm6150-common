#!/vendor/bin/sh
# RAM expansion controller untuk sweet. Metode mengikuti marble.

ramExpansion=$(getprop persist.vendor.ram_expansion)
if [ -z "$ramExpansion" ]; then
    ramExpansion=4
fi

case "$ramExpansion" in
    1) zRamSizeMB=1024 ;;
    2) zRamSizeMB=2048 ;;
    3) zRamSizeMB=3072 ;;
    4) zRamSizeMB=4096 ;;
    *) zRamSizeMB=4096 ;;
esac

# zram0 dipakai swap, jadi swap dilepas dulu sebelum ubah disksize.
swapoff /dev/block/zram0 2>/dev/null
sleep 1

for i in 1 2 3 4 5; do
    echo 1 > /sys/block/zram0/reset 2>/dev/null && break
    sleep 1
done

if [ -f /sys/block/zram0/max_comp_streams ]; then
    echo 8 > /sys/block/zram0/max_comp_streams 2>/dev/null
fi
if [ -f /sys/block/zram0/comp_algorithm ]; then
    echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null
fi

if [ -f /sys/block/zram0/disksize ]; then
    if [ -f /sys/block/zram0/use_dedup ]; then
        echo 1 > /sys/block/zram0/use_dedup 2>/dev/null
    fi
    echo "${zRamSizeMB}M" > /sys/block/zram0/disksize

    if [ -e /sys/kernel/slab/zs_handle ]; then
        echo 0 > /sys/kernel/slab/zs_handle/store_user 2>/dev/null
    fi
    if [ -e /sys/kernel/slab/zspage ]; then
        echo 0 > /sys/kernel/slab/zspage/store_user 2>/dev/null
    fi

    mkswap /dev/block/zram0
    swapon /dev/block/zram0 -p 32758
fi

echo 100 > /proc/sys/vm/swappiness 2>/dev/null
exit 0
