platform_check_image() {
	local board=$(board_name)
	local diskdev partdev diff
	[ "$#" -gt 1 ] && return 1

	v "Board is ${board}"

	export_bootdevice && export_partdevice diskdev 0 || {
		v "platform_check_image: Unable to determine upgrade device"
		return 1
	}

	get_partitions "/dev/$diskdev" bootdisk

	v "Extract boot sector from the image"
	get_image_dd "$1" of=/tmp/image.bs count=63 bs=512b

	get_partitions /tmp/image.bs image

	#compare tables
	diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image)"

	rm -f /tmp/image.bs /tmp/partmap.bootdisk /tmp/partmap.image

	if [ -n "$diff" ]; then
		v "Partition layout has changed. Full image will be written."
		ask_bool 0 "Abort" && exit 1
		return 0
	fi
}

platform_copy_config() {
	local partdev parttype=ext4

	if export_partdevice partdev 1; then
		part_magic_fat "/dev/$partdev" && parttype=vfat
		mount -t $parttype -o rw,noatime "/dev/$partdev" /mnt
		cp -af "$UPGRADE_BACKUP" "/mnt/$BACKUP_FILE"
		umount /mnt
	else
		v "ERROR: Unable to find partition to copy config data to"
	fi

	sleep 5
}

platform_do_bootloader_upgrade() {
	local bootpart parttable=msdos
	local diskdev="$1"

	if export_partdevice bootpart 1; then
		mkdir -p /tmp/boot
		mount -o rw,noatime "/dev/$bootpart" /tmp/boot
		echo "(hd0) /dev/$diskdev" > /tmp/device.map
		part_magic_efi "/dev/$diskdev" && parttable=gpt

		v "Upgrading bootloader on /dev/$diskdev..."

		umount /tmp/boot
	fi
}

platform_do_upgrade() {
	local board=$(board_name)
	local diskdev partdev diff

	export_bootdevice && export_partdevice diskdev 0 || {
		v "platform_do_upgrade: Unable to determine upgrade device"
		return 1
	}

	sync

	if [ "$UPGRADE_OPT_SAVE_PARTITIONS" = "1" ]; then
		get_partitions "/dev/$diskdev" bootdisk

		v "Extract boot sector from the image"
		get_image_dd "$1" of=/tmp/image.bs count=63 bs=512b

		get_partitions /tmp/image.bs image

		#compare tables
		diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image)"
	else
		diff=1
	fi

	if [ -n "$diff" ]; then
		# Need to remove partitions before dd, otherwise the partitions
		# that are added after will have minor numbers offset
		partx -d - "/dev/$diskdev"

		get_image_dd "$1" of="/dev/$diskdev" bs=4096 conv=fsync

		# Separate removal and addtion is necessary; otherwise, partition 1
		# will be missing if it overlaps with the old partition 2
		partx -a - "/dev/$diskdev"

		return 0
	fi

	#iterate over each partition from the image and write it to the boot disk
	while read part start size; do
		if export_partdevice partdev $part; then
			v "Writing image to /dev/$partdev..."
			get_image_dd "$1" of="/dev/$partdev" ibs=512 obs=1M skip="$start" count="$size" conv=fsync
		else
			v "Unable to find partition $part device, skipped."
		fi
	done < /tmp/partmap.image

	v "Writing new UUID to /dev/$diskdev..."
	get_image_dd "$1" of="/dev/$diskdev" bs=1 skip=440 count=4 seek=440 conv=fsync

	platform_do_bootloader_upgrade "$diskdev"
	local parttype=ext4
	part_magic_efi "/dev/$diskdev" || return 0

	if export_partdevice partdev 1; then
		part_magic_fat "/dev/$partdev" && parttype=vfat
		mount -t $parttype -o rw,noatime "/dev/$partdev" /mnt
		set -- $(dd if="/dev/$diskdev" bs=1 skip=1168 count=16 2>/dev/null | hexdump -v -e '8/1 "%02x "" "2/1 "%02x""-"6/1 "%02x"')
		sed -i "s/\(PARTUUID=\)[a-f0-9-]\+/\1$4$3$2$1-$6$5-$8$7-$9/ig" /mnt/boot/grub/grub.cfg
		umount /mnt
	fi
	# Provide time for the storage medium to flush before system reset
	# (despite the sync/umount it appears NVMe etc. do it in the background)
	sleep 5
}
