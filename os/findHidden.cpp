#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include <cmath>
#include <string>
int main(int argc, char *argv[]) {
    if (argc != 7) {
        std::cout << "Usage: " << argv[0] << " <output_file_path> <input_file_path> <partition path>\n";
        return 1;
    }
    const char* file_path = argv[1];
    std::string output_file(argv[1]);
    std::string input_file_size(argv[2]);
    std::string partition(argv[3]);
    std::string sec_per_cluster(argv[4]);
    std::string bytes_per_sec(argv[5]);
    std::string last_cluster_index(argv[6]);
    std::string parseFile = "temp";
    struct stat fileStat;
    struct stat input_fileStat;
    if(stat(file_path,&fileStat)==0){
        std::cout<<"OUTPUT file path: "<<output_file<<std::endl;
        std::cout<<"Physical size: "<<fileStat.st_size<<std::endl;
        std::cout<<"Logical size: "<<fileStat.st_blocks * 512<<std::endl;
        std::cout<<"Block size: "<<fileStat.st_blksize<<std::endl;
        std::cout<<"INode: "<<fileStat.st_ino<<std::endl;
    }


    int last_block = std::stoi(last_cluster_index);
    int bytes_per_sec_int = std::stoi(bytes_per_sec);
    int phys = fileStat.st_size;
    int phys_blocks_num = std::ceil(phys/float(bytes_per_sec_int));
    int sectors_to_write = fileStat.st_blocks - phys_blocks_num;
    int starting_sector = stoi(sec_per_cluster) - sectors_to_write;
    long long int bs = bytes_per_sec_int;
    long long int seek = (last_block) * stoi(sec_per_cluster)+starting_sector;
    int count = sectors_to_write;
    long long int skip = bs * seek;
    std::string command =  "sudo dd if="
                            +partition+" bs=1 skip="+
                            std::to_string(skip)+" count="+
                            input_file_size+" > out";
    std::cout<<command<<std::endl;
    system(command.c_str());
    return 0;
}


