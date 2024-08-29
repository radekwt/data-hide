partition=$1
#Bytes Per Sector	BPB_BytsPerSec	0x0B	16 Bits	Always 512 Bytes
sudo dd if="$partition" bs=1 skip=11 count=2 | xxd -p -c 2 > metadata.txt
#Sectors Per Cluster	BPB_SecPerClus	0x0D	8 Bits	1,2,4,8,16,32,64,128
sudo dd if="$partition" bs=1 skip=13 count=1 | xxd -p -c 1 >> metadata.txt #8 / 64
#Number of Reserved Sectors	BPB_RsvdSecCnt	0x0E	16 Bits	Usually 0x20
sudo dd if="$partition" bs=1 skip=14 count=2 | xxd -p -c 2 >> metadata.txt #32
#Number of FATs	BPB_NumFATs	0x10	8 Bits	Always 2
sudo dd if="$partition" bs=1 skip=16 count=1 | xxd -p -c 1 >> metadata.txt #2
#Sectors Per FAT	BPB_FATSz32	0x24	32 Bits	Depends on disk size
sudo dd if="$partition" bs=1 skip=36 count=4 | xxd -p -c 4 >> metadata.txt #8176 / 29344
#Root Directory First Cluster	BPB_RootClus	0x2C	32 Bits	Usually 0x00000002
sudo dd if="$partition" bs=1 skip=44 count=4 | xxd -p -c 4 >> metadata.txt #2